// utils.js
export const actionLog = (message) => {
	const actionLogSection = document.getElementById('actionLog'); 
	if (actionLogSection) {
		actionLogSection.value = actionLogSection.value ? `${actionLogSection.value}\n${message}` : message;
		actionLogSection.scrollTop = actionLogSection.scrollHeight;
	} else {
		console.warn('Action Log textarea not found');
	}
	console.log(`Action Log: ${message}`);
};

export const execCommand = (command, timeout = 5000, requiresRoot = true) => {
	let finalCommand = command;
	const [cmd] = command.split(' ');

	if (requiresRoot) {
		finalCommand = `su -c "${command}"`;
	}

	return Promise.race([
		new Promise((resolve, reject) => {
			const callbackName = `exec_callback_${Date.now()}`;
			window[callbackName] = (errno, stdout, stderr) => {
				delete window[callbackName];
				console.log(`Command: ${finalCommand}, errno: ${errno}, stdout: "${stdout}", stderr: "${stderr}"`);
				if (errno === 0) {
					resolve(stdout || '');
				} else {
					reject(new Error(`Command failed: ${stderr || 'No error message'}`));
				}
			};
			try {
				console.log(`Executing KernelSU command: ${finalCommand}`);
				ksu.exec(finalCommand, "{}", callbackName);
			} catch (error) {
				console.error(`KernelSU exec error: ${error}`);
				reject(`KernelSU exec error: ${error}`);
			}
		}),
		new Promise((_, reject) => setTimeout(() => reject(`Command timed out: ${finalCommand}`), timeout))
	]);
};

export const debounce = (func, wait) => {
	let timeout;
	return (...args) => {
		clearTimeout(timeout);
		timeout = setTimeout(() => func(...args), wait);
	};
};

export const isNumeric = (value) => {
	return !isNaN(parseFloat(value)) && isFinite(value);
};

export const getAdvancedRendererValue = (selectId, customInputsId) => {
	const selectElement = document.getElementById(selectId);
	
	if (!selectElement) {
		return null;
	}

	if (selectElement.value === 'custom') {
		const customContainer = document.getElementById(customInputsId); 
		if (!customContainer) {
			return null;
		}

		const customInputs = customContainer.querySelectorAll('input');
		
		const customValues = Array.from(customInputs).map(input => {
			return input.value.replace(',', '.');
		});
		return customValues.join(',');
	} else {
		return selectElement.value;
	}
};

export const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));