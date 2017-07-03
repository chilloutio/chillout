class PurchasesController < ApplicationController
  def create
    Chillout::Metric.push(
      series: "purchases",
      tags: {
        country: "USA",
        terminal: "KATE-123",
      },
      timestamp: Time.now.utc,
      values: {
        number_of_products: 4,
        total_amount: 55.70,
        tax: 5.70,
      },
    )
    head :ok
  end
end