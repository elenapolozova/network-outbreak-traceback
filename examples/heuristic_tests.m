% Example code: generates a new network, propagates an outbreak on it, and reports performance of heuristic methods

addpath('../utility'); % allow access to the other code

% Create small, simple network. 6 nodes per stage, each with in/out deg = 4.

% Set parameters
avg_deg = 3; 
node_counts = [6 6 6 6]; % formerly n1
init_vol_dist = 'bin';
network_params = cell(3, 4);
network_params(1, :) = {avg_deg, 'out', 'bin', 'bin'};
network_params(2, :) = {avg_deg, 'out', 'bin', 'bin'};
network_params(3, :) = {avg_deg, 'out', 'bin', 'bin'};
show_plots = true;
display_network = true;

% Create network linkages
[flows, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);
% Assign network locations
show_loc_plots = true;
[dists, node_locs] = assign_locations(node_layers, flows, show_loc_plots);

% Set up parameters to simulate a deterministic outbreak
dispersion = 'max';
src_farm = 1;
num_stages = 4;
return_all_reports = true;
plot_or_not = true;
transport_dev_frac = 0.0; % setting this number between 0 and 1 changes stochasticity of outbreak (0 is deterministic)
storage_is_determ = true; % true is deterministic, false isn't

% Simulate outbreak
[contam_farm, contam_reports] = outbreak(dispersion, src_farm, dists, ...
    node_locs, flows, init_vols, num_stages, return_all_reports, ...
    plot_or_not, transport_dev_frac, storage_is_determ);

% Define additional parameters necessary for traceback
distances = dists;
P = 0.9;
include_volumes = true;

heuristic_methods = 4:11;

summary_stats = zeros([8, stage_ends(1)+2]);
summary_stats(:, 1) = 4:11; % first col is method id, second is t_s_star, remaining cols are pmf

for method_id = heuristic_methods
    [pmf, t_s_stars] = time_traceback(method_id, flows, stage_ends, init_vols, contam_reports, distances, P, transport_dev_frac); 
    summary_stats(method_id-3, 2) = t_s_stars(1);
    summary_stats(method_id-3, 3:end) = pmf;
end

% don't pick out the single t_s_star, but if you were going to do that this is how you would
% max_prob_nodes = find(pmf == max(pmf)); % make array in case there's more than one
% max_prob_t_s_star = t_s_stars(max_prob_nodes(1));

'Printing summary statistics from all tracebacks...'
'[Method_ID    t_s_star_1    [pmf ...]]'

summary_stats





