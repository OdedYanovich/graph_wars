import cytoscape from 'cytoscape';
const graphId = 'g'
export function graphID() {
	return graphId
}
export function initGraph(nodes, edges) {
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
			rows: 3,
			cols: 4,
		},
	});
}
export function geTime() {
	return Date.now()
}
export function initKeydownEvent(keyDown, keyUp) {
	addEventListener("keydown", (event) => { if (!event.repeat) { return keyDown(event.key) } });
	addEventListener("keyup", (event) => keyUp(event.key));
}
