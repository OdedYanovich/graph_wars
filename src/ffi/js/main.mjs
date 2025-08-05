import cytoscape from 'cytoscape';
export function initGraph(graphId, nodes, edges) {
	console.log(edges.map((e) => { return { data: { id: e[0] + e[1], source: e[0], target: e[1] } } }))
	let id = cytoscape({
		container: document.getElementById(graphId),
		elements: nodes.map((e) => { return { data: { id: e } } }).concat(edges.map((e) => { return { data: { id: e[0] + e[1], source: e[0], target: e[1] } } })),
		style: [
			{
				selector: 'node',
				style: {
					shape: 'hexagon',
					'background-color': 'red',
					'color': '#FF0000',
					label: 'data(id)'
				}
			},
			{
				selector: 'edge',
				style: {
					'width': 3,
					'line-color': '#ccc',
					'target-arrow-color': '#ccc',
					'target-arrow-shape': 'triangle',
					'curve-style': 'bezier'
				}
			}]
	});
}
