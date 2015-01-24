global class BZNotifications {
	@future (callout=true)
	public static void notifyCampaignChanged() {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('http://platform.beyondz.org.arsdnet.net/salesforce/campaign_changed?id=0');
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		response.getBody();
	}
}
