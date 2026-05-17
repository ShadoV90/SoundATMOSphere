import { state } from './state.js';

export const cacheDomElements = () => {
	
	if (Object.keys(state.domCache).length > 0) {
		console.log('DOM cache already initialized:', Object.keys(state.domCache));
		return;
	}

	document.querySelectorAll('[id]').forEach((el) => {
		state.domCache[el.id] = el;
	});

	console.log('Cached DOM elements:', Object.keys(state.domCache));
	const criticalElements = [
		'output', 'dolbymi', 'hieq', 'hieqstr', 'hiet_47', 'heq_47',
		'dolbymiContainer', 'hieqContainer', 'hieqstr-value', 'heq47-value'
	];
	criticalElements.forEach(id => {
		if (!state.domCache[id]) {
			console.warn(`Critical element missing in DOM cache: ${id}`);
		} else {
			const value = state.domCache[id].value || state.domCache[id].getAttribute('data-state') || 'N/A';
			console.log(`Element ${id} found, value=${value}`);
		}
	});
};

export const getDomElement = (id) => {
	if (!state.domCache[id]) {
		state.domCache[id] = document.getElementById(id);
		if (!state.domCache[id]) {
			console.warn(`Element with id ${id} not found in DOM`);
		}
	}
	return state.domCache[id];
};