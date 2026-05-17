import { state } from '../shared/state.js';
import { updateOutput } from '../view/renderer.js';

export const initEndpointSettings = () => {
	const endpointSelects = [
		'htunedrate',
		'stunedrate',
		'h_output_channels',
		's_output_channels'
	];

	endpointSelects.forEach(id => {
		const selectElement = state.domCache[id];
		if (selectElement) {
			selectElement.addEventListener('input', () => {
				updateOutput();
			});
		} else {
			console.warn(`Endpoint setting element with id "${id}" was not found in the DOM cache.`);
		}
	});
};