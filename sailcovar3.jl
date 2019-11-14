using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, Kp[1:4] >= 0)
@variable(m, Zp[1:4] >= 0)  
@variable(m, hI[1:4] >= 0)
@variable(m, hD[1:4] >= 0)  
@constraint(m, hI[4]>=10)
@constraint(m, hD[4]<=0) 
@constraint(m, x[1]+y[1]-50== Kp[1]+Zp[1])
@constraint(m, loop[i in 2:4], x[i]+y[i]-(x[i-1]+y[i-1])==Kp[i]+Zp[i])     # conservation of boats
@constraint(m, 10+x[1]+y[1]-40== hI[1]-hD[1])
@constraint(m, secondloop[i in 2:4], hI[i-1]-hD[i-1]+x[i]+y[i]-d[i]==hI[i]+hD[i])     # conservation of boats
@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hI)+400*sum(Kp)+500*sum(Zp)+100*sum(hD))         # minimize costs
optimize!(m)
@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Objective cost: %f\n", objective_value(m))