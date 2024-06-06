# Redes-Neuronales

## Ajuste de Parámetros de un Modelo de Ecuaciones Diferenciales en Julia

Este repositorio contiene un script en Julia para ajustar los parámetros de un modelo basado en ecuaciones diferenciales utilizando datos experimentales de conversión. Se utilizan varias librerías de Julia para manejar los datos, definir el modelo, resolver las ecuaciones diferenciales y optimizar los parámetros.

## Requisitos

- Julia 1.5 o superior
- Paquetes de Julia:
  - `CSV`
  - `DataFrames`
  - `DifferentialEquations`
  - `DiffEqFlux`
  - `Flux`
  - `Plots`
  - `ComponentArrays`
  - `Optimization`
  - `OptimizationOptimisers`
  - `OptimizationOptimJL`

## Uso

1. Cargar los Datos
2. Definir Parámetros Iniciales
3. Definir la Ecuación Diferencial
4. Configurar el Problema de Ecuaciones Diferenciales
5. Definir Funciones de Predicción y Pérdida
6. Optimización de Parámetros
7. Mostrar Resultados

## Visualización

Durante el proceso de optimización, se generan gráficos para comparar los datos observados y las predicciones del modelo.

## Contribución

Si encuentras algún error o tienes sugerencias para mejorar el script, por favor abre un issue o un pull request.

## Licencia

Este proyecto está licenciado bajo los términos de la MIT License.
