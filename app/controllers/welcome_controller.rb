class WelcomeController < ApplicationController
  def index
  end

  def generator
    @cycle_number = params[:cycle_number].to_i || 1
    @x_dim = params[:x_dim].to_i || 10
    @y_dim = params[:y_dim].to_i || 10
    @coordinates = generate_coords @x_dim, @y_dim, @cycle_number
    @cycle_number = @cycle_number + 1
  end

  private
    def generate_coords k, m, n
      Array.new(n){[rand(1..k), rand(1..m)]}
    end
end
