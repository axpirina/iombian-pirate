#!/bin/bash -e

INSTALLATION_PATH="/opt/hivemq-mqtt-web-client"

if [ -d "$INSTALLATION_PATH" ]; then
  rm -rf ${INSTALLATION_PATH}
fi

HIVEMQ_COMMIT="33b947b5694e93cf65f53a601ec1e2389f1eb287"

git clone --no-checkout https://github.com/hivemq/hivemq-mqtt-web-client.git $INSTALLATION_PATH
git -C $INSTALLATION_PATH checkout $HIVEMQ_COMMIT
chown -R $FIRST_USER_NAME:$FIRST_USER_NAME $INSTALLATION_PATH

# enable systemd service
systemctl enable mqtt-web-client.service
