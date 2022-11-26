#Catch Per Unit Effort CPUE####
#Author: Chris Hinds
#22 Nov 2022

get_annual_catch {LeMaRns}	R Documentation
Get annual catch for each species, catch per unit effort or catch per gear
Description
Get annual catch for each species, the Catch Per Unit Effort (CPUE) or the Catch Per Gear (CPG)

Usage
get_annual_catch(inputs, outputs, ...)

## S4 method for signature 'missing,missing'
get_annual_catch(
  Catch,
  years = (dim(Catch)[3] + (inc_first - 1)) * phi_min,
  phi_min = 0.1,
  inc_first = FALSE
)

## S4 method for signature 'LeMans_param,missing'
get_annual_catch(
  inputs,
  Catch,
  years = (dim(Catch)[3] + (inc_first - 1)) * inputs@phi_min,
  inc_first = FALSE
)

## S4 method for signature 'LeMans_param,LeMans_outputs'
get_annual_catch(
  inputs,
  outputs,
  years = (dim(outputs@Catch)[3] + (inc_first - 1)) * inputs@phi_min,
  inc_first = FALSE
)

## S4 method for signature 'missing,LeMans_outputs'
get_annual_catch(
  outputs,
  years = (dim(outputs@Catch)[3] + (inc_first - 1)) * phi_min,
  phi_min = 0.1,
  inc_first = FALSE
)

get_CPUE(inputs, outputs, ...)

## S4 method for signature 'LeMans_param,LeMans_outputs'
get_CPUE(inputs, outputs, effort, years = nrow(effort), inc_first = FALSE)

## S4 method for signature 'LeMans_param,missing'
get_CPUE(inputs, Catch, effort, years = nrow(effort), inc_first = FALSE)

## S4 method for signature 'missing,LeMans_outputs'
get_CPUE(
  outputs,
  Qs,
  effort,
  years = nrow(effort),
  phi_min = 0.1,
  inc_first = FALSE
)

## S4 method for signature 'missing,missing'
get_CPUE(
  Catch,
  Qs,
  effort,
  years = nrow(effort),
  phi_min = 0.1,
  inc_first = FALSE
)

get_CPG(inputs, outputs, ...)

## S4 method for signature 'LeMans_param,LeMans_outputs'
get_CPG(inputs, outputs, effort, years = nrow(effort), inc_first = FALSE)

## S4 method for signature 'LeMans_param,missing'
get_CPG(inputs, Catch, effort, years = nrow(effort), inc_first = FALSE)

## S4 method for signature 'missing,LeMans_outputs'
get_CPG(
  outputs,
  Qs,
  effort,
  years = nrow(effort),
  phi_min = 0.1,
  inc_first = FALSE
)

## S4 method for signature 'missing,missing'
get_CPG(
  Catch,
  Qs,
  effort,
  years = nrow(effort),
  phi_min = 0.1,
  inc_first = FALSE
)
Arguments
inputs	
A LeMans_param object containing the parameter values of the current LeMans model.

outputs	
A LeMans_outputs object containing the outputs of the model run.

...	
Additional arguments.

Catch	
An array with dimensions nsc, nfish and tot_time representing the number of individuals in each length class for each time step.

years	
A numeric value representing the number of years included in Catch.

phi_min	
A numeric value representing the time step of the model.

inc_first	
A logical statement indicating whether the first time step of Catch should be included. The default is FALSE.

effort	
A matrix with dimensions years and the number of fishing gears, representing fishing effort in each year for each gear.

Qs	
An array of dimensions nsc, nfish and gear representing the catchability of each species by each of the fishing gears.

Value
get_annual_catch returns a matrix with dimensions years and length(species) where the i,jth element represents the total catch (g) of the jth species in the ith year.

get_CPUE returns a matrix with dimensions tot_time and nfish where the i,jth element represents the CPUE in the ith time step for the jth species.

get_CPG returns an array with dimensions nfish, dim(Qs[3]) and the number of time steps, where the i,j,kth element denotes the total catch of the ith species by the jth gear in the kth time step.

Examples
# Set up and run the model
NS_params <- LeMansParam(NS_par, tau=NS_tau, eta=rep(0.25, 21), L50=NS_par$Lmat, other=1e12)
effort <- matrix(0.5, 10, dim(NS_params@Qs)[3])
model_run <- run_LeMans(NS_params, years=10, effort=effort)

# Get annual catch
get_annual_catch(inputs=NS_params, outputs=model_run)

# Calculate the CPUE
get_CPUE(inputs=NS_params, outputs=model_run, effort=effort)

# Calculate Catch Per Gear (CPG)
get_CPG(inputs=NS_params, outputs=model_run, effort=effort)
[Package LeMaRns version 0.1.2 Index]