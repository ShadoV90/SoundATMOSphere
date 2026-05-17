import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { convertToLanguageNumerals } from '../shared/language.js';
import { updateOutput } from '../view/renderer.js';

export const initVolBoost = () => {
	const hVolBoost = getDomElement('hvolboost');
	const hVolBoostDisplay = getDomElement('hvolboost-value');

	if (hVolBoost && hVolBoostDisplay) {
		const updateHPBoostLabel = () => {
			const lang = state.domCache.languageSelect?.value || 'en';
			hVolBoostDisplay.textContent = convertToLanguageNumerals(hVolBoost.value, lang) + ' dB';
		};

		hVolBoost.addEventListener('input', () => {
			updateHPBoostLabel();
			updateOutput();
		});
		setTimeout(() => {
			updateHPBoostLabel();
		}, 20);
	}
	const hVolBalance = getDomElement('hvolbalance');
	const hVolBalanceDisplay = getDomElement('hvolbalance-value');

	if (hVolBalance && hVolBalanceDisplay) {
		const updateBalanceLabel = () => {
			const lang = state.domCache.languageSelect?.value || 'en';
			const val = parseFloat(hVolBalance.value);
			let displayText = '';
			if (val < 0) {
				const num = convertToLanguageNumerals(String(Math.abs(val)), lang); 
				displayText = `R -${num} dB`;
				
			} else if (val > 0) {
				const num = convertToLanguageNumerals(String(Math.abs(val)), lang);
				displayText = `L -${num} dB`;
				
			} else {
				const zero = convertToLanguageNumerals('0', lang);
				displayText = `${zero}:${zero} dB`; 
			}
			
			hVolBalanceDisplay.textContent = displayText;
		};

		hVolBalance.addEventListener('input', () => {
			updateBalanceLabel();
			updateOutput();
		});
		setTimeout(() => {
			updateBalanceLabel();
		}, 20);
	}
	const sVolBoost = getDomElement('svolboost');
	const sVolBoostDisplay = getDomElement('svolboost-value');

	if (sVolBoost && sVolBoostDisplay) {
		const updateSPKBoostLabel = () => {
			const lang = state.domCache.languageSelect?.value || 'en';
			sVolBoostDisplay.textContent = convertToLanguageNumerals(sVolBoost.value, lang) + ' dB';
		};

		sVolBoost.addEventListener('input', () => {
			updateSPKBoostLabel();
			updateOutput();
		});
		setTimeout(() => {
			updateSPKBoostLabel();
		}, 20);
	}
	
};