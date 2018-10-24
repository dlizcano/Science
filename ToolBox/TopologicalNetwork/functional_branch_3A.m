%   ********************  FUNCTIONAL_BRANCH_V3 ************************
%
% Función que calcula: Fragmentación, Acumulación y Propagación de
% una red fluvial topológica. Estos análisis permiten caracterizar la red fluvial, 
% para posteriormente evaluar los impactos acumulativos de un conjunto de obras 
% de infrastructura como embalses, diques, etc., localizadas en una red fluvial, 
% en términos de perdida de Rios Libres, efectos aguas abajo por modificación del 
% régimen de caudales y sedimentos, entre otros.
%
% Version 3.Beta.  Please do not share without permision of the autor
% 
% FUNCTION OUTPUTS:
% -------------------
%   functional_network_arcs               : vector que asigna a cada 
%                                           tramo de la red fluvial
%                                           el ID del obstáculo localizado aguas abajo (e.g.
%                                           un embalse). Todos los tramos
%                                           que tengan el mismo valor de
%                                           "functional_network_arcs"
%                                           pertenecen a una misma red
%                                           fluvial conectada. Por defecto,
%                                           la red de la desembocadura,
%                                           se identifica con el functional_network_arcs
%                                           = 0
%   cumulative_upstream_vars              : matriz con el valor
%                                           acumulado aguas arriba de un cada tramo fluvial, de las 
%                                           variables suministradas por el usuario para cada tramo fluvial en la variable 
%                                           de entrada 'network_vars_to_accumulate'. 
%   propagated_upstream_vars              : matriz con el valor aguas arriba de un cada tramo fluvial diferente de 0, de las 
%                                           variables suministradas por el usuario para cada tramo fluvial en la variable 
%                                           de entrada 'network_vars_to_propagate'. 
%   cumulative_upstream_var_w_retention   : matriz con el valor
%                                           acumulado aguas arriba de un cada tramo fluvial, de las 
%                                           variables suministradas por el usuario para cada tramo fluvial en la variable 
%                                           de entrada 'network_vars_to_acum_w_retention', considerando tambien el porcentaje  
%                                           de retención asignado por el usuario a cada tramo fluvial. 
%   cumulative_freeriver_vars             : matriz con el valor
%                                           acumulado en rios libres (entre barreras), de las 
%                                           variables suministradas por el usuario para cada tramo fluvial en la variable 
%                                           de entrada 'network_vars_freeriver_to_accumulate'. 
%
% 
% FUNCTION INPUTS:
% -------------------
%
%  start_id_downstream             : Identificador de tramo fluvial
%                                    localizado mas aguas abajo de la red
%                                    fluvial (e.i. ID del tramo fluvial que
%                                    correpsonde a la desembocadura del
%                                    rio).
%  arc_ids                         : Vector que contiene los ID de todos
%                                    los tramos fluviales
%  arc_start_nodes y arc_end_nodes : Vectores que contienen la topología de
%                                    la red fluvial. Respectivamente
%                                    permiten identificar los nodos inicial
%                                    y final de cada tramo fluvial
%  arc_barrier                     : vector que contiene, para cada tramo
%                                    fluvial el identificador de la barrera
%                                    presente en el tramo. Si no hay
%                                    ninguna barrera en el tramo, utilizar
%                                    0.
%  current_network_id              : ID definido por el usuario para la red fluvial que
%                                    correpsonde a la desembocadura del
%                                    rio. Se recomienda 0.
%  network_vars_to_accumulate      : Conjunto de variables en cada tramo fluvial que el
%                                    usuario desea acumular hacia aguas
%                                    abajo. Puede ser por ejemplo, el
%                                    volumen de almacenamiento de los
%                                    embalses 
%  cumulative_status               : Utilizar network_vars_to_accumulate. 
%                                    Esta variable es utilizada internamente por 
%                                    el algoritmo de recursivo.   
%  network_vars_to_propagate       : Conjunto de variables en cada tramo fluvial que el
%                                    usuario desea propagar hacia aguas
%                                    abajo. Puede ser por ejemplo, la carga
%                                    de contanimantes conservativos vertidos en un tramo fluvial.  
%  propagation_status              : Utilizar network_vars_to_propagate. 
%                                    Esta variable es utilizada internamente por 
%                                    el algoritmo recursivo.   
%  network_var_to_acum_w_retention : Variable en cada tramo fluvial que el
%                                    usuario desea acumular hacia aguas
%                                    abajo, considerando el proceso de
%                                    retención. Esta variable puede ser el
%                                    aporte de sediumentos en cada tramo
%                                    fluvial.
%  arc_retention_rate              : Vector que contiene para cada tramo fluvial 
%                                    el prámetro de tasa de retención
%                                    (porcentaje)
%  acum_w_retention_status         : Utilizar network_vars_to_acumw_retention. 
%                                    Esta variable es utilizada internamente por 
%                                    el algoritmo recursivo.  
%  network_vars_freeriver to_accumulate      : Conjunto de variables en cada tramo fluvial que el
%                                              usuario desea acumular hacia aguas
%                                              abajo en las redes de rios libres (entre barreras). 
%                                              Puede ser por ejemplo, la longitud de tramos de río
%                                              
%  freeriver_cumulative_status               : Utilizar network_vars_freeriver_to_accumulate. 
%                                              Esta variable es utilizada internamente por 
%                                              el algoritmo recursivo.   

function [functional_network_arcs, cumulative_upstream_vars, propagated_upstream_vars, cumulative_upstream_var_w_retention,cumulative_freeriver_vars] = functional_branch_3A(start_id_downstream, arc_ids, arc_start_nodes, arc_end_nodes, ...
                                                                          arc_barrier, current_network_id, ...
                                                                          network_vars_to_accumulate, cumulative_status, ...
                                                                          network_vars_to_propagate, propagation_status, ... 
                                                                          arc_retention_rate, network_var_to_acum_w_retention, acum_w_retention_status,...
                                                                          network_vars_freeriver_to_accumulate, freeriver_cumulative_status)
    functional_network_arcs = 0 * arc_ids;
    [r c] = size(network_vars_to_accumulate);
    
    cumulative_upstream_vars = cumulative_status; 
    propagated_upstream_vars = propagation_status;
    cumulative_upstream_var_w_retention = acum_w_retention_status;
    cumulative_freeriver_vars = freeriver_cumulative_status;
    
    current_id = start_id_downstream;
    n = find(arc_ids == current_id);
    
    num_branches = 1;
    
    while num_branches == 1;
        
        functional_network_arcs(n) = current_network_id;
        
        if (arc_barrier(n) > 0)                      % a barrier was found, a new functional network must be assigned to upstream reaches:
            new_network_id = arc_barrier(n);         % uses barrier_id as network_id for upstream network
        else
            new_network_id = current_network_id;
        end
               
        n_prev = n;
        n = find(arc_end_nodes == arc_start_nodes(n)); % keeps going upstream

        [num_branches c] = size(n);
       
        if num_branches > 1           
            for i = 1:num_branches 
                start_sub_id = arc_ids(n(i));
                [f_arc_ids_n, cum_vars, prop_vars, cum_vars_w_retention,cum_freeriver_vars] = functional_branch_3A(start_sub_id, arc_ids, arc_start_nodes, arc_end_nodes, ...
                                                             arc_barrier,new_network_id, ... 
                                                             network_vars_to_accumulate, cumulative_upstream_vars, ... 
                                                             network_vars_to_propagate, propagated_upstream_vars, ...
                                                             arc_retention_rate, network_var_to_acum_w_retention, cumulative_upstream_var_w_retention,...
                                                             network_vars_freeriver_to_accumulate, cumulative_freeriver_vars);

                functional_network_arcs = functional_network_arcs + f_arc_ids_n;
                
                cumulative_upstream_vars = cum_vars;
                cumulative_upstream_vars(n_prev,:) = cumulative_upstream_vars(n_prev,:) + cum_vars(n(i),:);
                
                propagated_upstream_vars = prop_vars;
                propagated_upstream_vars(n_prev,:) = propagated_upstream_vars(n_prev,:) + prop_vars(n(i),:);  % propagated vars are accumulated at confluence points
                
                cumulative_upstream_var_w_retention =  cum_vars_w_retention;
                cumulative_upstream_var_w_retention(n_prev,:) = (cumulative_upstream_var_w_retention(n_prev,:) + cum_vars_w_retention(n(i),:));
                
                cumulative_freeriver_vars = cum_freeriver_vars;
                cumulative_freeriver_vars(n_prev,:) = cumulative_freeriver_vars(n_prev,:) + cum_freeriver_vars(n(i),:);
            end
        end
        
        cumulative_upstream_var_w_retention(n_prev,:) = cumulative_upstream_var_w_retention(n_prev,:) * (1 - arc_retention_rate(n_prev)/100);
   
        if (arc_barrier(n_prev) > 0)                      % a barrier was found, resets river network accumulation:
            cumulative_freeriver_vars(n_prev,:) = network_vars_freeriver_to_accumulate(n_prev,:);
        end

        if (network_vars_to_propagate(n_prev) > 0)
            propagated_upstream_vars(n_prev) = network_vars_to_propagate(n_prev);
        end
    end  
end
