class HealthController < ApplicationController
  def show
    render json: {
      status: "ok",
      app: "Atlas Commerce API",
      version: "1.0.0",
      timestamp: Time.current.iso8601,
      database: database_status
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute("SELECT 1")
    "connected"
  rescue StandardError
    "unavailable"
  end
end
