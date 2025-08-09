export function initKeydownEvent(keyDown, keyUp) {
	addEventListener("keydown", (event) => { if (!event.repeat) { return keyDown(event.key) } });
	addEventListener("keyup", (event) => keyUp(event.key));
}
