# ZoneBilling Connector for Workato #

## Owners ##

* [Zone & Co. Software Consulting LLC](https://zoneandco.com)

## How do I connect to NetSuite via the Workato Connector? ##

NetSuite supports OAuth 1.0, OAuth2.0, and Token Based Authentication (TBA) for connecting to the system. _This connector only supports OAuth2.0 (Machine to Machine)_. 

OAuth1.0 and TBA are not currently supported as the user experience did not meet requirements. The [ZoneBilling API](https://zab-docs.zoneandco.com/) still supports these methods via other connection capabilities. 

### OAuth2.0 (Machine to Machine) ###

1. **Turn on Required Features**
    1. ~TBD~
2. **Create an Integration Record in NetSuite**
    1. In NetSuite, navigate to Setup > Integrations > Manage Integrations > New
    2. Fill out the following:
        * _Name_: 'ZoneBilling for Workato Connector'
        * _TBA Authorization Flow_: false
        * _Token-Based Authentication_: false
        * _Authorization Code Grant_: false
        * _Client Credentials (Machine to Machine) Grant_: true
        * _Scope - Restlets_: true
        * _Scope - Rest Web Services_: true
    3. Upon save, you will be presented with two unique values that will only be shown once, _Consumer Key_ and _Consumer Secret_. Save these as you will need them for a later step
3. **Create certificate and private key**
    1. Generate an encrypted certificate and related private key using the ES256 standard. This is the only encryption standard accepted by both NetSuite and Workato
        * On a Mac:
            1. Navigate to the folder/directory which you want these files to be saved (Eg. Downloads, Documents, etc.)
            2. Right click on the folder, and select "New Terminal At Folder"
            3. Generate a ES256 private key and a signed certificate with they key by entering the following command: `openssl ecparam -name prime256v1 -genkey -noout -out workato_private.pem && openssl req -new -x509 -key workato_private.pem -out workato_cert.pem -days 730`
                * The terminal will ask you questions, these answers are used to generated the "randomness" of the certificate. These answers do not matter and do not need to be remebered.
        * On a PC:
            1. Open Powershell on a PC (this comes pre-installed on most modern Windows machines)
            2. Navigate to your preferred location to save the keys with commands
            3. Generate a ES256 private key with the following command `openssl ecparam -name prime256v1 -genkey -noout -out workato_private.pem`
            4. Create a certificate signed with this private key by entering the following command `openssl req -new -x509 -key workato_private.pem -out workato_cert.pem -days 730`
                * The terminal will ask you questions, these answers are used to generated the "randomness" of the certificate. These answers do not matter and do not need to be remebered.
    2. This will create two files `workato_private.pem` and `workato_cert.pem` in the desired folder, take note of these as you will need them for a later step
4. **Upload Certifcate to NetSuite**
    1. In NetSuite, navigate to Setup > Integrations > OAuth 2.0 Client Credentials (M2M) Setup
    2. Create New Certifcate
        * _Entity_: Select the integrating user, either a dedicated user profile for this integration or some other user such as yourself
        * _Role_: Select a valid role assigned to the selected user that has appropriate permissions to perform integrations activities.
        * _Application_: Select the Integration created in Step 2
    3. Upon save, take note that the algorithm for the certificate created is EC (representing ECDSA) and the Integration ID, which we will need for a future step
5. **Configure Workato Connection**
    1. Create new Connection
    3. `NetSuite Account ID`: Input the respective account ID for the production, sandbox, or development account  
        * This is specifically the url prefix for the NetSuite account (Eg. 1234567-SB1, 1234567, TSTDRV1234567), not the account number
        * Sandbox account IDs with a `_` seperator will not work at this time
    4. `Certificate ID`: Set the value of the certificate ID identified in step 4
    5. `Consumer Key`: Set the value of the consumer key received in step 2
    6. `Private Key`: Set the value within the `workato_private.pem` file generated in step 3
        * Open the file with TextEdit or other text editor on a Mac
6. **Hit Connect!**
    1. You are all set to connect to NetSuite and use the ZoneBilling Workato Connector!
7. **Notices**
    1. Please note that NetSuite only allows a certificate to be used for up to 2 year (730 days). So this process will need to be intermittently refreshed with new certifcates and keys before the expiration date
