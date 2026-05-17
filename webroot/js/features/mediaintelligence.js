import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { updateOutput } from '../view/renderer.js';

export const initMediaIntelligence = () => {
	const lang = state.domCache.languageSelect?.value || 'en';
	const toggleIds = [
		'dolbymidvlev',
		'dolbymiieq',
		'dolbymisurcomp',
		'dolbymiadaptvirt',
		'dolbymivirtbin',
		'dolbymidialenh'
	];
	toggleIds.forEach(id => {
		const toggle = getDomElement(id);

		if (toggle) {
			toggle.addEventListener('click', () => {
				const isOn = toggle.getAttribute('data-state') === 'true';
				const newState = !isOn;

				toggle.setAttribute('data-state', newState);
				toggle.textContent = newState ? state.translations[lang]['on'] : state.translations[lang]['off'];
				toggle.classList.toggle('active', newState);
				updateOutput();
			});
		}
	});
};