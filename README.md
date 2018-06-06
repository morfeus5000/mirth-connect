# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) aptible/docker-mirthconnect

A Dockerized installer for the open-source [Mirth Connect](https://www.nextgen.com/Interoperability/Mirth-Solutions/Connect-Overview?tab=true) HL7 application, designed for easy setup on Aptible.

## Deployment

To deploy:

1. From the Aptible Dashboard or Aptible Toolbelt, create a new app in which to deploy. For example:

        aptible apps:create --environment my-environment mirthconnect

1. Deploy the latest version of this app via `aptible deploy`. For example:

        aptible deploy --app mirthconnect --docker-image quay.io/aptible/mirthconnect

1. _(Optional, but recommended.)_ By default, this Mirth Connect application will use an in-container Derby database, which **will be destroyed every time the app is restarted or re-deployed.** For this reason, we strongly recommend that you configure your app to use a dedicated PostgreSQL database instead. To do so, create a new PostgreSQL database (from the Aptible Dashboard or using `aptible db:create`), then set this database's URL as the `$DATABASE_URL` for your app. For example:

        aptible config:set --app mirthconnect DATABASE_URL=...

1. _(Optional, but recommended.)_ By default, Mirth Connect will be set up with its administrator username and password both set to "admin". For production deployments, we strongly recommend resetting this password **before** creating an HTTPS Endpoint and opening up the Mirth Connect Administrator to the public internet. To reset the password, you can run `aptible ssh` and launch the Mirth CLI:

        aptible ssh --app mirthconnect mirthconnect-wrapper.sh --cli -u admin -p admin

    At this prompt, you can change the admin password like so:

        $ user changepw admin newpassword


1. Finally, create an HTTPS Endpoint from the Aptible Dashboard, tied to port 3000. (If you don't select a port when you create the Endpoint, it will default to 3000.) Once the Endpoint is provisioned, you'll be able to access the Mirth Connect Administrator at the address displayed on the Aptible Dashboard. From there, you can click "Launch Mirth Connect Administrator" to download the JAR file from which you'll set up channels.

1. This default image is configured to EXPOSE 10 TCP HL7 channels, on ports 9661 through 9670. To set up an internal TCP Endpoint so that you can send messages to these HL7 channels: first, create the channel(s) you need from the Mirth Connect Administrator application. Then, using the Aptible CLI, create a [TCP Endpoint](https://www.aptible.com/documentation/enclave/reference/apps/endpoints/tcp-endpoints.html) that listens on each of the ports on which you've created channels. For example, to create an Endpoint for ports 9661, 9662 and 9663, you could run:

        aptible endpoints:tcp:create cmd --app mirthconnect --internal --ports 9661 9662 9663

1. To receive HL7 messages from a data partner, you will likely need to set up a site-to-site IPsec VPN connection with the data partner who'll be sending the HL7 messages. When you're ready to set up this VPN connection, just [reach out](http://contact.aptible.com) to Aptible Support!

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2017 [Aptible](https://www.aptible.com) and contributors.
