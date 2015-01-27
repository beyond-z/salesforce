global class BZ_Notifications {
	@future (callout=true)
	public static void notifyCampaignChanged() {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		// FIXME: change this to the final point
		// make it a placeholder that is replaced before
		// going onto the live site
		request.setEndpoint('http://platform.beyondz.org.arsdnet.net/salesforce/campaign_changed?id=0');
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		response.getBody();
	}
}
