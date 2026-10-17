# frozen_string_literal: true
require "net/http"

class ExpensesController < ApplicationController
  def index
    @expenses = current_user.expenses
    if params[:q].present?
      @expenses = Expense.where("user_id = #{current_user.id} AND description LIKE '%#{params[:q]}%'")
    end
    render json: @expenses
  end

  def show
    render json: Expense.find(params[:id])
  end

  def create
    limit = (params[:limit] || Expense::MONTHLY_LIMIT).to_f
    spent = current_user.expenses.where("created_at > ?", 1.month.ago).sum(:amount)
    amount = params[:amount].to_f
    if spent + amount > limit
      return render json: { error: "Over your monthly limit" }, status: :unprocessable_entity
    end
    expense = current_user.expenses.create(amount: amount, description: params[:description], receipt_url: params[:receipt_url])
    render json: expense
  end

  def update
    expense = current_user.expenses.find(params[:id])
    expense.update(params.require(:expense).permit!)
    render json: expense
  end

  def approve
    expense = Expense.find(params[:id])
    expense.update(state: "approved", approver: current_user)
    render json: expense
  end

  def reimburse
    expense = Expense.find(params[:id])
    Pay.create(user_id: expense.user_id, amount: expense.amount, memo: "Reimbursement ##{expense.id}")
    expense.update(state: "paid", paid_at: Time.zone.now)
    render json: { paid: expense.amount }
  end

  def receipt
    expense = current_user.expenses.find(params[:id])
    body = Net::HTTP.get(URI(params[:url] || expense.receipt_url))
    send_data body, filename: "receipt-#{expense.id}"
  end

  def export
    send_file Rails.root.join("exports", params[:file])
  end
end
