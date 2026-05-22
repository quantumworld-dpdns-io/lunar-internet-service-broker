module CapacityPlanning

using JuMP
using HiGHS

export optimize_allocation, forecast_demand, price_optimization

"""
Optimize bandwidth allocation across multiple rovers and relays.
"""
function optimize_allocation(
    rover_demands::Vector{Float64},
    relay_capacities::Vector{Float64},
    cost_matrix::Matrix{Float64},
)
    n_rovers = length(rover_demands)
    n_relays = length(relay_capacities)

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, x[1:n_rovers, 1:n_relays] >= 0)

    @constraint(model, demand[i=1:n_rovers], sum(x[i, :]) <= rover_demands[i])
    @constraint(model, capacity[j=1:n_relays], sum(x[:, j]) <= relay_capacities[j])

    @objective(model, Min, sum(cost_matrix[i, j] * x[i, j] for i=1:n_rovers, j=1:n_relays))

    optimize!(model)

    return (
        status = string(termination_status(model)),
        objective = objective_value(model),
        allocation = value.(x),
        constraint_duals = dual.(capacity),
    )
end

"""
Forecast demand based on historical usage patterns.
"""
function forecast_demand(
    historical_data::Vector{Float64},
    horizon::Int,
)::Vector{Float64}
    if length(historical_data) < 2
        return fill(mean(historical_data), horizon)
    end

    n = length(historical_data)
    slope = (historical_data[end] - historical_data[1]) / n
    intercept = historical_data[1]

    return [intercept + slope * (n + t) for t in 1:horizon]
end

"""
Optimize pricing for capacity offers.
"""
function price_optimization(
    base_cost::Float64,
    demand_elasticity::Float64,
    competitor_prices::Vector{Float64},
    target_margin::Float64,
)::Float64
    avg_competitor = mean(competitor_prices)
    optimal_price = base_cost * (1 + target_margin)

    if optimal_price > avg_competitor * 1.2
        optimal_price = avg_competitor * 1.2
    end

    return optimal_price
end

end
