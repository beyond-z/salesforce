trigger BZ_EnableApplyNow on Campaign (after update) {
	BZ_Notifications.notify();
}
