using JuMP, Cbc, PrettyTables

m = Model(Cbc.Optimizer)

# input data
c = 15 # production capacity
dem = [10, 15, 20, 8, 35] # customer demsnd
Lt = 1 # production lead time
Lc = 100 # late cost
Sp = 50 # selling price
Sc = 15 # inventory cost
Pc = 20 # production cost

# variables
@variable(m, Nr[1:5] >= 0) # net requirement
@variable(m, St[0:5] >= 0) # stock
@variable(m, La[0:5] >= 0) # Late products
@variable(m, Dl[0:5] >= 0) # Delivered products
@variable(m, Rp[0:5] >= 0) # Replenishment

# initial parameters
@constraint(m, St[0] == 30)
@constraint(m, Rp[0] == 0)
@constraint(m, La[0] == 0)

# constratints
@constraint(m, [t = 0:5], Rp[t] <= c) # production capacity at every time period
@constraint(m, [t = 1:5], St[t] == St[t - Lt] - dem[t] + Rp[t - Lt] + La[t]) # balanced quantities at every time period
@constraint(m, [t = 1:5], Nr[t] == Rp[t - Lt]) # quantities launch
@constraint(m, [t = 1:5], La[t] == La[t - Lt] + dem[t] - Dl[t])
@constraint(m, [t = 0:5], St[t] >= 0)

@objective(m, Max, sum(Nr[t] * Sp - (La[t] * Lc + St[t] * Sc + Rp[t] * Pc) for t=1:5))

optimize!(m)

println("Objective is: ", JuMP.objective_value(m))

header = ["t","Dm","St","Nr","Rp","Dl","La"]
t = 0:5
data = hcat(t, pushfirst!(convert(Vector{Union{Int64, String}}, dem), "-"), JuMP.value.(St), pushfirst!(convert(Vector{Union{Float64, String}}, JuMP.value.(Nr)), "-"), JuMP.value.(Rp), JuMP.value.(Dl), JuMP.value.(La))
pretty_table(data, header)
