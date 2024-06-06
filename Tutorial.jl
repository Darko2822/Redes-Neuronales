using CSV
using DataFrames
using DifferentialEquations
using DiffEqFlux, Flux
using Plots
using ComponentArrays
using Optimization
using OptimizationOptimisers
using OptimizationOptimJL

# Cargar datos de conversión
datos = CSV.read("Datos02.txt", delim='\t', header=false, DataFrame)

# Tiempo
t_obs = datos[:, 1]

# Conversión
X_obs = datos[:, 2]

# Parámetros iniciales
Y_A = 0.12
N_A0 = 11.09
N_B0 = 30.49
N_C0 = 17.55
N_G0 = 15.70
N_H0 = 17.55
delta = (1 + 1/2 + 1/2 - 1 - 2 - 1/2)
P = 1
T = 277
V_0 = 2.1

# Definir la ecuación diferencial
function derivada!(dX, X, p, t)
    k1, k2, k3, k4, k5, k6, k8 = p

    theta_A = (N_A0 / N_A0)
    theta_B = (N_B0 / N_A0)
    theta_C = (N_C0 / N_A0)
    theta_G = (N_G0 / N_A0)
    theta_H = (N_H0 / N_A0)

    C_A0 = N_A0 / V_0

    epsilon = delta * Y_A

    C_A = C_A0 * (theta_A - X[1]) / (1 + epsilon * X[1])
    C_B = C_A0 * (theta_B - 2 * X[1]) / (1 + epsilon * X[1])
    C_C = C_A0 * (theta_C - 0.5 * X[1]) / (1 + epsilon * X[1])
    C_G = C_A0 * (theta_G) / (1 + epsilon * X[1])
    C_H = C_A0 * (theta_H) / (1 + epsilon * X[1])

    r_A = -2 * k8 * C_C * (k3 * C_A * C_G + k2 * C_A * ((k1 * C_B^2 + 2 * k4 * C_B) / (k2 * C_A + k5 * C_H + k6 * C_B)))

    dX[1] = (-r_A * (1 + epsilon * X[1])) / C_A0
end

# Parámetros iniciales para el ajuste
p_ini = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1] 

# Definir el problema de la ecuación diferencial con los parámetros iniciales
u0 = [0.0]  # Condición inicial
tspan = (0.0, maximum(t_obs))

prob = ODEProblem(derivada!, u0, tspan, p_ini)

# Función de predicción
function predict(p)
    solve(remake(prob, p=p), Tsit5(), saveat=t_obs)
end

# Función de pérdida
function loss(p)
    pred_sol = predict(p)
    sum((pred_sol[1, :] .- X_obs).^2)
end

# Callback para visualización
function callback(p, l, pred; doplot=true)
    println("Loss: ", l)
    if doplot
        plt = scatter(t_obs, X_obs, label="Datos observados")
        scatter!(plt, t_obs, [u[1] for u in pred.u], label="Predicción")
        display(plot(plt))
    end
    return false
end

# Inicializar los parámetros
pinit = ComponentArray(p_ini)

# Mostrar el primer ajuste
callback(pinit, loss(pinit), predict(pinit); doplot=true)

# Función de pérdida para Optimization.jl
function loss_neuralode(p)
    return loss(p), predict(p)
end

# Usar Optimization.jl para resolver el problema
adtype = Optimization.AutoZygote()

optf = Optimization.OptimizationFunction((x, p) -> loss_neuralode(x), adtype)
optprob = Optimization.OptimizationProblem(optf, pinit)

result_neuralode = Optimization.solve(
    optprob, OptimizationOptimisers.Adam(0.01); callback=callback, maxiters=1000
)

# Ajuste final con BFGS
optprob2 = remake(optprob; u0=result_neuralode.u)

result_neuralode2 = Optimization.solve(
    optprob2, OptimizationOptimJL.BFGS(); callback=callback, allow_f_increases=false
)

# Mostrar el ajuste final
callback(result_neuralode2.u, loss_neuralode(result_neuralode2.u)[1], loss_neuralode(result_neuralode2.u)[2]; doplot = true)

# Obtener los valores finales de los parámetros
final_params = result_neuralode2.u
println("Valores finales de los parámetros: ", final_params)