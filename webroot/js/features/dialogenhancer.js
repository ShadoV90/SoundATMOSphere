import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { convertToLanguageNumerals } from '../shared/language.js';
import { updateOutput } from '../view/renderer.js';

export const initDialogEnhancer = () => {
	const lang = state.domCache.languageSelect?.value || 'en';

	// Headphone dialog enhancer
	const hDe = getDomElement('hde');
	if (hDe) {
		hDe.addEventListener('change', () => {
			const value = hDe.value;
			updateOutput();
		});
	}

	// Speaker dialog enhancer
	const sDe = getDomElement('sde');
	if (sDe) {
		sDe.addEventListener('change', () => {
			const value = sDe.value;
			updateOutput();
		});
	}

	// Sliders
	const sliders = ['hdea', 'hded', 'sdea', 'sded'];
	sliders.forEach(id => {
		const slider = getDomElement(id);
		if (slider) {
			slider.addEventListener('input',() => {
				const valueDisplay = getDomElement(`${id}-value`);
				if (valueDisplay) {
					valueDisplay.textContent = convertToLanguageNumerals(slider.value, lang);
				}
				updateOutput();
			});
		}
	});
};