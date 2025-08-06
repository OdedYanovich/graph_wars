import cytoscape from 'cytoscape';
export function initGraph(graphId, nodes, edges) {
	let edgeNagativeCounter = 0
	let id = cytoscape({
		container: document.getElementById(graphId),
		elements: nodes.map((e) => { return { data: { id: e } } }).concat(edges.map((e) => { edgeNagativeCounter -= 1; return { data: { id: edgeNagativeCounter, source: e[0], target: e[1] } } })),
		style: [
			{
				selector: 'node',
				style: {
					shape: 'hexagon',
					'background-color': 'red',
					'color': '#FFFFFF',
					label: 'data(id)'
				}
			},
			{
				selector: 'edge',
				style: {
					'width': 8,
					'line-color': '#25c',
					'target-arrow-color': '#0c0',
					'target-arrow-shape': 'triangle',
					'curve-style': 'bezier',
					label: 'data(id)',
					'color': '#FFFFFF',
				}
			}],

		layout: {
			name: 'grid',
			rows: 2,
			cols: 2,
		},
	});
}
