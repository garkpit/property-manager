export let messageRefreshCounter = $state(0);

export function triggerMessageRefresh() {
    messageRefreshCounter++;
}
