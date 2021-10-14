/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const { SYNC_SERVICE_SID } = context;

  let response = new Twilio.Response();

  const { EventType } = event;

  if (EventType == 'document_updated') {
    const { DocumentUniqueName, DocumentData, Identity } = event;
    const syncService = context.getTwilioClient().sync.services(SYNC_SERVICE_SID);

    // TODO: Use filename to verify what kind of document this is
    try {
      const [documentType, roomSid] = DocumentUniqueName.split('-');

      if (documentType === 'viewer') {
        const raisedHandsMapName = `raised_hands-${roomSid}`;
        const documentData = JSON.parse(DocumentData);

        // TODO: Handle if item is already in or removed from map
        if (documentData.hand_raised) {
          // Add to map
          await syncService.syncMaps(raisedHandsMapName).syncMapItems.create({ key: Identity, data: {} });
        } else {
          // Remove from map
          await syncService.syncMaps(raisedHandsMapName).syncMapItems(Identity).remove();
        }
      }
    } catch (e) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error updating map item',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  response.setStatusCode(200);
  return callback(null, response);
};
