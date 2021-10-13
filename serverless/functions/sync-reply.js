/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  // TODO: Handle webhook security
  
  const { SYNC_SERVICE_SID } = context;

  let response = new Twilio.Response();

  const { EventType } = event;
  
  if (EventType == 'document_updated') {
    const { DocumentUniqueName, DocumentData, Identity } = event;
    const syncService = context.getTwilioClient().sync.services(SYNC_SERVICE_SID);

    // TODO: Use filename to verify what kind of document this is
    try {
      const documentNameComponents = DocumentUniqueName.split('-');
      const documentType = documentNameComponents[0];

      if (documentType == 'viewer') {
        const roomSid = documentNameComponents[1];
        const mapName = `raised_hands-${roomSid}`
        const documentDataJSON = JSON.parse(DocumentData);

        // TODO: Handle if item is already in or removed from map
        if (documentDataJSON.hand_raised) {
          // Add to map
          await syncService.syncMaps(mapName).syncMapItems.create({key: Identity, data: { } })
        } else {
          // Remove from map
          await syncService.syncMaps(mapName).syncMapItems(Identity).remove();
        }
      }
    } catch (e) {
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
