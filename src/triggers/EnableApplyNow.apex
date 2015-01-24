trigger EnableApplyNow on Campaign (after update) {
	BZNotifications.notify();
}
