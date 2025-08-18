import cytoscape from 'cytoscape';
let cy
const graphId = 'g'
export function initGraph(elements) {
	cy = cytoscape({
		container: document.getElementById(graphId),
		elements: elements,
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
export function removeElement(id) {
	cy.$('#' + id).remove()
}
export function addElement(element) {
	cy.add(element)
}
export function graphID() {
	return graphId
}
