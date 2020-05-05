using JuMP, Cbc

profit = [5, 3, 2, 7, 4]
weight = [2, 8, 4, 2, 5]
capacity = 10

m = Model(Cbc.Optimizer)
@variable(m, x[1:5], Bin)
@constraint(m, sum(weight[i] * x[i] for i=1:length(profit)) <= capacity)
@objective(m, Max, sum(profit[i]*x[i] for i=1:length(profit)))
optimize!(m)

println("Objective is: ", JuMP.objective_value(m))
for i in 1:5
    println("x[$i] = ", JuMP.value(x[i]))
end
