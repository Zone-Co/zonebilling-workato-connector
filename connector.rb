# frozen_string_literal: true

{

  title: 'ZoneBilling for NetSuite',

  connection: {
    base_uri: lambda do |connection|
      ## NetSuite Sandbox accounts have ID's are format with a _ (eg. 1234567_SB1)
      ## The URL is formatted with a hyphen (eg. 1234567-sb1)
      account_id = connection['account_id'].gsub('_', '-')

      "https://#{account_id}.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=customscriptzab_api_restlet&deploy=customdeployzab_api_restlet".downcase
    end,

    fields: [
      {
        name: "auth_type",
        control_type: "select",
        pick_list: [
          ["OAuth 1.0", "ns_oauth1"],
          ["OAuth 2.0", "ns_oauth2"],
          ["OAuth 2.0 (Machine to Machine)", "ns_oauth2_m2m"],

        ],
        default: "ns_oauth1",
        extends_schema: true
      }
    ],

    authorization: {

      type: "multi",

      options: {

        'ns_oauth1': {
          type: "custom_auth",

          fields: [
            {
              name: 'account_id',
              label: 'NetSuite Account ID',
              optional: false
            },
            {
              name: 'token_id',
              label: 'Token ID',
              optional: false,
              control_type: 'password'
            },
            {
              name: 'token_secret',
              label: 'Token Secret',
              optional: false,
              control_type: 'password'
            },
            {
              name: 'client_id',
              label: 'Consumer Key',
              optional: false,
              control_type: 'password'
            },
            {
              name: 'client_secret',
              label: 'Consumer Secret',
              optional: false,
              control_type: 'password'
            }
          ],

          refresh_on: [
            403
          ],

          apply: lambda do |connection|

            ## Gather All URL Parameters ##
            url_parts = current_url.split('?')
            base_url = url_parts[0].downcase
            param_parts = url_parts[1].split('&')
            url_params = {}

            param_parts.each do |param_string|
              param_split = param_string.split('=')
              param_key = param_split[0]
              url_params[param_key] = param_split[1]
            end

            ## Account Configuration ##
            account_id = connection['account_id']
            signature_method = "HMAC-SHA256"
            version = "1.0"
            timestamp = Time.now.to_i.to_s
            nonce = timestamp + 'zabnonce'

            token_id = connection['token_id']
            consumer_key = connection['client_id']
            consumer_secret = connection['client_secret']
            token_secret = connection['token_secret']

            ## Organize all Parameters together, alphabetically
            final_params = {
              'oauth_consumer_key' => consumer_key,
              'oauth_nonce' => nonce,
              'oauth_signature_method' => signature_method,
              'oauth_timestamp' => timestamp,
              'oauth_token' => token_id,
              'oauth_version' => version,
            }.merge(url_params).sort_by { |key, value| key}

            ## Generate Signature from url components, keys, and tokens
            param_string = final_params.map{|key, value|
              "#{key}=#{value}"
            }.join('&')

            base_string = [current_verb.to_s.upcase.encode_url, base_url.encode_url, param_string.encode_url].join('&')
            key = [consumer_secret.encode_url, token_secret.encode_url].join('&')
            signature = base_string.hmac_sha256(key).encode_base64

            authorization = "OAuth realm=\"#{account_id.upcase}\"," \
              "oauth_consumer_key=\"#{consumer_key}\"," \
              "oauth_token=\"#{token_id}\"," \
              "oauth_signature_method=\"#{signature_method}\"," \
              "oauth_timestamp=\"#{timestamp}\"," \
              "oauth_nonce=\"#{nonce}\"," \
              "oauth_version=\"#{version}\"," \
              "oauth_signature=\"#{signature}\""

            ## Set Headers
            headers(
              'Content-Type' => 'application/json',
              'Authorization' => authorization
            )
          end
        },

        'ns_oauth2': {
          type: "oauth2",

          authorization_url: lambda do |connection|
            "https://#{connection['account_id']}.app.netsuite.com/app/login/oauth2/authorize.nl?scope=restlets&response_type=code"
          end,

          token_url: lambda do |connection|
            "https://#{connection['account_id']}.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token"
          end,

          fields: [
            {
              name: 'account_id',
              label: 'NetSuite Account ID',
              optional: false
            },
            {
              name: 'client_id',
              label: 'Consumer Key',
              optional: false,
              control_type: 'password'
            },
            {
              name: 'client_secret',
              label: 'Consumer Secret',
              optional: false,
              control_type: 'password'
            }
          ],

          client_id: lambda do |connection|
            connection['client_id']
          end,

          client_secret: lambda do |connection|
            connection['client_secret']
          end,

          apply: lambda do |connection, access_token|
            headers(
              'Authorization' => "Bearer #{access_token}",
              'Content-Type' => 'application/json'
            )
          end
        },

        'ns_oauth2_m2m': {
          type: "custom_auth", ## Per Workato Documentation, we want to use this since it is a 'JWT' integration

          fields: [
            {
              name: 'account_id',
              label: 'NetSuite Account ID',
              hint: 'This can be found in the URL of your NetSuite account.
                Your production account ID will be 7-digits (eg. 1234567),
                your sandbox ID will include a hyphen and the sandbox number (eg. 1234567-sb1)',
              optional: false
            },
            {
              name: 'certificate_id',
              label: 'Certificate ID',
              hint: 'This is the ID generated by NetSuite after you upload the certificate file to
                the OAuth 2.0 Client Credentials Setup page. This is found under
                Setup > Integration > OAuth 2.0 Client Credentials (M2M) Setup within NetSuite.',
              optional: false,
              control_type: :text
            },
            {
              name: 'client_id',
              label: 'Consumer Key',
              hint: 'This is provided by NetSuite when creating the integration record in the system.
                This is found under Setup > Integration > Managed Integrations > New within NetSuite.',
              optional: false,
              control_type: 'password'
            },
            {
              name: 'private_key',
              label: 'Private Key',
              hint: "This is the contents of the private key file used to sign the certificate that was uploaded to
                NetSuite's 'OAuth 2.0 Client Credentials Setup page'",
              optional: false,
              control_type: 'password',
              multiline: true
            }
          ],

          acquire: lambda do |connection|
            ### NetSuite Sandbox accounts have ID's formatted as 1234567_SB1, but the URL is formatted with a hyphen
            ### (eg. 1234567-sb1)
            account_id = connection['account_id'].gsub('_', '-')
            endpoint = "https://#{account_id}.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token".downcase

            jwt_body_claim = {
              "iss": connection['client_id'],
              "scope": %w[restlets rest_webservices],
              "aud": endpoint,
              "exp": 1.hour.from_now.to_i,
              "iat": now.to_i
            }

            private_key = connection['private_key'].gsub(/\\n/, "\n")

            jwt_token = workato.jwt_encode(
              jwt_body_claim,
              private_key,
              'ES256',
              kid: connection['certificate_id']
            )

            post(endpoint).payload(
              grant_type: 'client_credentials',
              client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
              client_assertion: jwt_token
            ).request_format_www_form_urlencoded
          end,

          detect_on: [401, 403],

          refresh_on: [401, 403],

          apply: lambda do |connection|
            # Access Token is added to the connection hash via the acquire method
            access_token = connection['access_token']

            headers(
              'Authorization' => 'Bearer #{access_token}',
              'Content-Type' => 'application/json'
            )
          end
        }
      }
    }
  },

  test: lambda do |connection|
    ## All NetSuite Accounts have this record type, this ZAB API Export
    ## We want a short page_size and short page_number to receive a quick response
    params = {
      export_id: 'zab_api_export',
      page_size: 5,
      page_number: 1
    }

    call(:get, connection, params)
  end,

  actions: {
    "create_record": {
      title: 'Create Record',

      subtitle: 'Create a Standard, ZoneBilling or Custom record in NetSuite',

      description: lambda do |_input, picklist_label|
        "Create a <span class='provider'>#{picklist_label['record_type'] || 'record'}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 100,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          object_definitions['post_input_options'],
          object_definitions['record_fields']
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'create')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_response']
      end,

      summarize_output: ['results'],

      retry_on_response: [403, /INVALID_LOGIN_ATTEMPT/, /Invalid login attempt/],

      max_retries: 3,

      sample_output: lambda do |connection, input|
        call(:get_post_sample_response, connection, input)
      end
    },

    "update_record": {
      title: 'Update Record',

      subtitle: 'Update a Standard, ZoneBilling or Custom record in NetSuite',

      description: lambda do |_input, picklist_label|
        "Update a <span class='provider'>#{picklist_label['record_type'] || 'record'}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 100,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'external_key',
          label: 'Identifier',
          optional: false,
          sticky: true,
          default: 'internalid',
          hint: 'Select the field on the record type to be used as the primary key.',
          control_type: :select,
          pick_list: 'record_fields',
          pick_list_params: {
            record_type: 'record_type'
          },
          toggle_hint: 'Select',
          toggle_field: {
            name: 'external_key',
            label: 'Identifier',
            hint: 'Indicate the field ID on the record type to be used as the primary key.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          object_definitions['post_input_options'],
          object_definitions['record_fields']
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'update')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_response']
      end,

      summarize_output: ['results'],

      sample_output: lambda do |connection, input|
        call(:get_post_sample_response, connection, input)
      end
    },

    "upsert_record": {
      title: 'Upsert Record',

      subtitle: 'Upsert a Standard, ZoneBilling or Custom record in NetSuite',

      description: lambda do |_input, picklist_label|
        "Upsert a <span class='provider'>#{picklist_label['record_type'] || 'record'}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 100,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'external_key',
          label: 'Identifier',
          optional: false,
          sticky: true,
          default: 'internalid',
          hint: 'Select the field on the record type to be used as the primary key.',
          control_type: :select,
          pick_list: 'record_fields',
          pick_list_params: {
            record_type: 'record_type'
          },
          toggle_hint: 'Select',
          toggle_field: {
            name: 'external_key',
            label: 'Identifier',
            hint: 'Indicate the field ID on the record type to be used as the primary key.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          object_definitions['post_input_options'],
          object_definitions['record_fields']
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'upsert')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_response']
      end,

      summarize_output: ['results'],

      sample_output: lambda do |connection, input|
        call(:get_post_sample_response, connection, input)
      end
    },

    "create_records_batch": {
      title: 'Create Records',

      subtitle: 'Create multiple Standard, ZoneBilling or Custom records in NetSuite',

      description: lambda do |_input, picklist_label|
        "Create multiple <span class='provider'>#{picklist_label['record_type'] || 'record'}s</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 44,

      batch: true,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: [
              object_definitions['automations_option'],
              object_definitions['external_references']
            ].flatten
          },
          {
            name: 'records',
            label: 'Records',
            sticky: true,
            type: :array,
            list_mode: 'dynamic',
            item_label: 'Record',
            of: :object,
            properties: object_definitions['record_fields']
          }
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'create')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_batch_response']
      end,

      summarize_input: ['records'],

      sample_output: lambda do |_connection, _input|
        {
          reference_id: 12_345
        }
      end
    },

    "update_records_batch": {
      title: 'Update Records',

      subtitle: 'Update multiple Standard, ZoneBilling or Custom records in NetSuite',

      description: lambda do |_input, picklist_label|
        "Update multiple <span class='provider'>#{picklist_label['record_type'] || 'record'}s</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 42,

      batch: true,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'external_key',
          label: 'Identifier',
          optional: false,
          sticky: true,
          default: 'internalid',
          hint: 'Select the field on the record type to be used as the primary key.',
          control_type: :select,
          pick_list: 'record_fields',
          pick_list_params: {
            record_type: 'record_type'
          },
          toggle_hint: 'Select',
          toggle_field: {
            name: 'external_key',
            label: 'Identifier',
            hint: 'Indicate the field ID on the record type to be used as the primary key.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: [
              object_definitions['automations_option'],
              object_definitions['external_references']
            ].flatten
          },
          {
            name: 'records',
            label: 'Records',
            sticky: true,
            list_mode: 'dynamic',
            item_label: 'Record',
            type: :array,
            of: :object,
            properties: object_definitions['record_fields']
          }
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'update')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_batch_response']
      end,

      summarize_input: ['records'],

      sample_output: lambda do |_connection, _input|
        {
          reference_id: 12_345
        }
      end
    },

    "upsert_records_batch": {
      title: 'Upsert Records',

      subtitle: 'Upsert multiple Standard, ZoneBilling or Custom records in NetSuite',

      description: lambda do |_input, picklist_label|
        "Update multiple <span class='provider'>#{picklist_label['record_type'] || 'record'}s</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 40,

      batch: true,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the target record type in NetSuite',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the target record type ID in NetSuite',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'external_key',
          label: 'Identifier',
          optional: false,
          sticky: true,
          default: 'internalid',
          hint: 'Select the field on the record type to be used as the primary key.',
          control_type: :select,
          pick_list: 'record_fields',
          pick_list_params: {
            record_type: 'record_type'
          },
          toggle_hint: 'Select',
          toggle_field: {
            name: 'external_key',
            label: 'Identifier',
            hint: 'Indicate the field ID on the record type to be used as the primary key.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: [
              object_definitions['automations_option'],
              object_definitions['external_references']
            ].flatten
          },
          {
            name: 'records',
            label: 'Records',
            sticky: true,
            list_mode: 'dynamic',
            item_label: 'Record',
            type: :array,
            of: :object,
            properties: object_definitions['record_fields']
          }
        ].flatten
      end,

      execute: lambda do |connection, input|
        call(:post, connection, input, 'upsert')
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_batch_response']
      end,

      summarize_input: ['records'],

      sample_output: lambda do |_connection, _input|
        {
          reference_id: 12_345
        }
      end
    },

    "post_automation": {
      title: 'Run ZAB Automation(s)',

      subtitle: 'Kick off a configured ZAB Automation, or select multiple to run them chained.',

      description: lambda do |input, picklist_label|
        value = input['automations'] || []
        automations = value.split(',')
        index = automations.length > 1 ? 2 : automations.length

        label_indexes = [
          'a ZAB Automation',                     # No Automation selected, Default value
          picklist_label['automations'],          # 1 Automation Selected, show label
          "#{automations.length} ZAB Automations" # 2 or More Automations, show "multiple"
        ]

        "Kick off <span class='provider'>#{label_indexes[index]}</span> in <span class='provider'>NetSuite</span>"
      end,

      display_priority: 5,

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['automations_option']
      end,

      execute: lambda do |connection, input|
        call(:post, connection, {
               'options' => input
             }, nil)
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['post_response']
      end,

      summarize_output: ['results'],

      sample_output: lambda do |_connection, _input|
        {
          reference_id: 1234
        }
      end
    },

    "get_process_status": {
      title: 'Get Bulk API Status',

      subtitle: 'Get the status and results of a Bulk API request or other ZoneBilling process.',

      description: lambda do |input, _picklist_label|
        label = input['process_id'] ? "ZAB Process ID: #{input['process_id']}" : 'a ZAB Process'
        "Get the status for <span class='provider'>#{label}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 10,

      batch: true,

      config_fields: [
        {
          name: 'process_id',
          label: 'Process ID',
          hint: 'Indicate the Process ID you would like to gather details on.',
          control_type: :select,
          pick_list: 'processes',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'process_id',
            label: 'Process ID',
            hint: 'Indicate the Internal ID of the ZAB Process you want to monitor',
            control_type: :integer,
            extends_schema: true,
            change_on_blur: true,
            type: :integer,
            optional: false,
            toggle_hint: 'Internal ID'
          }
        }
      ],

      execute: lambda do |_connection, input|
        params = {
          batch_reference_id: input['process_id']
        }
        get('', params) || {}
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['batch_response']
      end,

      summarize_output: %w[results errors],

      sample_output: lambda do |_connection, input|
        params = {
          batch_reference_id: input['process_id']
        }
        get('', params) || {}
      end
    },

    "get_records": {
      title: 'Get Records',

      subtitle: 'Get data from NetSuite by collecting the results of saved searches via configured ZAB API Exports.',

      description: lambda do |_input, picklist_label|
        "Collect results from <span class='provider'>#{picklist_label['export_id'] || 'a ZAB API Export'}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 54,

      config_fields: [
        {
          name: 'export_id',
          label: 'ZAB API Export',
          hint: 'Select a pre-configured ZAB API Export record
            that corresponds to a saved search of records within your NetSuite account.',
          pick_list: 'api_exports',
          control_type: :select,
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'export_id',
            label: 'ZAB API Export',
            hint: 'Indicate the specific ZAB API Export ID configured in your environment
              that you would like to retrieve.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            toggle_hint: 'Export ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: [
              object_definitions['get_options_request'],
              object_definitions['get_options_response']
            ].flatten
          },
          {
            name: 'dynamic_filters',
            label: 'Filters',
            hint: 'Indicate additional filters to dynamically refine the results of your ZAB API Export.',
            sticky: true,
            type: :object,
            properties: object_definitions['get_export_filters']
          }
        ]
      end,

      execute: lambda do |connection, input|
        call(:get_export_id, connection, input)
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['get_response']
      end,

      summarize_output: ['results'],

      sample_output: lambda do |connection, input|
        response = call(:get_export_id, connection, input) || {
          page: 1,
          total_pages: 5,
          total_results: 4500,
          results_returned: 1000,
          results: []
        }

        response
      end
    },

    "get_record": {
      title: 'Get Record',

      subtitle: 'Get a specific record from NetSuite from a configured ZAB API Export.',

      description: lambda do |_input, picklist_label|
        "Get Record from <span class='provider'>#{picklist_label['export_id'] || 'a ZAB API Export'}</span> in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 55,

      config_fields: [
        {
          name: 'export_id',
          label: 'ZAB API Export',
          hint: 'Select a pre-configured ZAB API Export record that corresponds
            to a saved search of records within your NetSuite account.',
          pick_list: 'api_exports',
          control_type: :select,
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'export_id',
            label: 'ZAB API Export',
            hint: 'Indicate the specific ZAB API Export ID configured in your environment
              that you would like to retrieve.',
            extends_schema: true,
            change_on_blur: true,
            control_type: :string,
            type: :string,
            toggle_hint: 'Export ID'
          }
        },
        {
          name: 'internal_id',
          label: 'Identifier',
          hint: 'Specifiy a specific record internal id you would like to retrieve',
          control_type: :integer,
          type: :integer,
          sticky: true,
          toggle_hint: 'Internal ID',
          toggle_field: {
            name: 'external_id',
            label: 'Identifier',
            hint: 'Specifiy a specific record external id you would like to retreieve.',
            control_type: :integer,
            type: :integer,
            toggle_hint: 'External ID'
          }
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: object_definitions['get_options_response']
          }
        ]
      end,

      execute: lambda do |connection, input|
        result = call(:get_export_id, connection, input)

        results = result['results'] || []

        if results.empty?
          identifier = if input['internal_id']
                         "Internal ID: #{input['internal_id']}"
                       else
                         "External ID: #{input['external_id']}"
                       end
          error("No Record was found for #{identifier}")
        end

        results.first
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        response = object_definitions['get_response'] || {}
        index = response.find_index do |field|
          field['name'] == 'results'
        end
        result_details = response[index]

        result_details['properties']
      end,

      sample_output: lambda do |connection, input|
        result = call(:get_export_id, connection, input)

        results = result['results'] || []

        results.first
      end
    },

    "get_record_file": {
      title: 'Get Record File',

      subtitle: "Get a specific record's related print file from NetSuite.",

      description: lambda do |_input, picklist_label|
        "Get <span class='provider'>#{picklist_label['record_type'] || 'Record'}</span> File from " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 50,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the record type you are looking to export.',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate the record type ID you are looking to export.',
            control_type: :string,
            extends_schema: true,
            change_on_blur: true,
            type: :string,
            optional: false,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'record_id',
          label: 'Record ID',
          hint: 'Specifiy the specific record internal ID you would like to retrieve',
          type: :integer,
          control_type: :integer,
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: object_definitions['file_export_options']
          }
        ]
      end,

      execute: lambda do |connection, input|
        call(:get_record_file, connection, input)
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['get_file_response']
      end,

      sample_output: lambda do |_connection, _input|
        {
          name: 'INV000001.PDF',
          description: '... File Description ... ',
          contents: '... File Contents ...'
        }
      end
    },

    "get_record_file_attachments": {
      title: 'Get Record File Attachments',

      subtitle: "Get a specific record's file attachments within NetSuite.",

      description: lambda do |_input, picklist_label|
        "Get <span class='provider'>#{picklist_label['record_type'] || 'Record'}</span>'s' File Attachments from " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 49,

      config_fields: [
        {
          name: 'record_type',
          label: 'Record Type',
          hint: 'Select the record type you are looking to export.',
          control_type: :select,
          pick_list: 'record_types',
          optional: false,
          toggle_hint: 'Select',
          toggle_field: {
            name: 'record_type',
            label: 'Record Type',
            hint: 'Indicate  the record type you are looking to export.',
            change_on_blur: true,
            extends_schema: true,
            control_type: :string,
            type: :string,
            toggle_hint: 'ID'
          }
        },
        {
          name: 'record_id',
          label: 'Record ID',
          hint: 'Specifiy the specific record internal ID you would like to retrieve',
          type: :integer,
          control_type: :integer,
          optional: false
        }
      ],

      execute: lambda do |connection, input|
        call(:get_record_file_attachments, connection, input)
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        [
          {
            name: 'files',
            label: 'Files',
            type: :array,
            of: :object,
            properties: object_definitions['get_file_response']
          }
        ]
      end,

      sample_output: lambda do |_connection, _input|
        {
          files: [
            {
              name: 'INV000001.PDF',
              description: '... File Description ... ',
              contents: '... File Contents ...'
            }
          ]
        }
      end
    },

    "get_file": {
      title: 'Get File',

      subtitle: 'Get a file from the NetSuite File Cabinet.',

      description: lambda do |_input, _picklist_label|
        "Get a <span class='provider'>File</span> from the File Cabinet in " \
          "<span class='provider'>NetSuite</span>"
      end,

      display_priority: 48,

      config_fields: [
        {
          name: 'record_id',
          label: 'File ID',
          hint: 'Specifiy the specific file ID you would like to retrieve from the File Cabinet',
          type: :integer,
          control_type: :integer,
          optional: false
        }
      ],

      execute: lambda do |connection, input|
        input['record_type'] = 'file'
        input['options'] = {
          file_export_type: 'filecabinetfile'
        }

        call(:get_record_file, connection, input)
      end,

      output_fields: lambda do |object_definitions, _connection, _config_fields|
        object_definitions['get_file_response']
      end,

      sample_output: lambda do |_connection, _input|
        {
          name: 'INV000001.PDF',
          description: '... File Description ... ',
          contents: '... File Contents ...'
        }
      end
    }

  },

  custom_action: true,

  custom_action_help: {
    learn_more_url: 'https://zab-docs.zoneandco.com/',

    learn_more_text: 'ZoneBilling API Documentation',

    body: '<p>Build your own ZoneBilling action with a HTTP request.
      <b>The request will be authorized with your ZoneBilling NetSuite connection.</b></p>'
  },

  pick_lists: {

    api_exports: lambda do |connection|
      results = []

      params = {
        export_id: 'zab_api_export'
      }

      response = call(:get, connection, params) || {}

      response['results'].each do |result|
        results.push(
          [
            # Picklist Name
            result['name']['value'],
            # API Name
            result['custrecordzab_apixport_export_id']['value']
          ]
        )
      end

      results
    end,

    automations: lambda do |connection|
      results = []
      params = {
        export_id: 'zab_automation'
      }

      response = call(:get, connection, params) || {}
      response['results'].each do |result|
        id = result['name']['value']
        name = result['altname']['value']
        type = result['custrecordzab_a_processes']['text']

        results.push(
          [
            # Picklist Name
            "#{id}: #{name} (#{type})",
            # API Name
            result['internalid']['value']
          ]
        )
      end

      results
    end,

    file_compression_type: lambda do |_connection|
      [
        %w[CPIO cpio],
        %w[TAR tar],
        %w[TBZ2 tbz2],
        %w[TGZ tgz],
        %w[ZIP zip]
      ]
    end,

    file_export_type: lambda do |_connection|
      [
        %w[PDF recordpdf],
        %w[HTML recordhtml]
      ]
    end,

    filter_types: lambda do |_connection|
      [
        ['Default', 'filter'],
        ['Date', 'filterdate'],
        ['Date/Time', 'filterdatetime']
      ]
    end,

    operators: lambda do |_connection|
      [
        ['After', 'after'],
        ['All of', 'allof'],
        ['Any', 'any'],
        ['Any Of', 'anyof'],
        ['Before', 'before'],
        ['Between', 'between'],
        ['Contains', 'contains'],
        ['Does not contain', 'doesnotcontain'],
        ['Does not start with', 'doesnotstartswith'],
        ['Equal To', 'equalto'],
        ['Greater Than', 'greaterthan'],
        ['Greater Than or Equal To', 'greaterthanorequalto'],
        ['Has Keywords', 'haskeywords'],
        ['Is', 'is'],
        ['Is Empty', 'isempty'],
        ['Is Not', 'isnot'],
        ['Is Not Empty', 'isnotempty'],
        ['Less Than', 'lessthan'],
        ['Less Than or Equal To', 'lessthanorequalto'],
        ['None Of', 'noneof'],
        ['Not After', 'notafter'],
        ['Not All Of', 'notallof'],
        ['Not Before', 'notbefore'],
        ['Not Between', 'notbetween'],
        ['Not Equal To', 'notequalto'],
        ['Not Greater Than', 'notgreaterthan'],
        ['Not Greater Than or Equal To', 'notgreaterthanorequalto'],
        ['Not Less Than', 'notlessthan'],
        ['Not Less Than or Equal To', 'notlessthanorequalto'],
        ['Not On', 'noton'],
        ['Not On or After', 'notonorafter'],
        ['Not On or Before', 'notonorbefore'],
        ['Not Within', 'notwithin'],
        ['On', 'on'],
        ['On or After', 'onorafter'],
        ['On or Before', 'onorbefore'],
        ['Starts With', 'startswith'],
        ['Within', 'within']
      ]
    end,

    processes: lambda do |connection|
      results = []
      params = {
        export_id: 'zab_process'
      }

      response = call(:get, connection, params) || {}
      response['results'].each do |result|
        name_details = result['name'] || {}
        name = name_details['value']
        type_details = result['custrecordzab_p_process'] || {}
        type = type_details['text']

        results.push(
          [
            # Picklist Name
            "#{name} (#{type})",
            # API Name
            result['internalid']['value']
          ]
        )
      end

      results
    end,

    record_types: lambda do |connection|
      call(:get_record_types, connection)
    end,

    record_fields: lambda do |connection, record_type:|
      call(:get_record_fields, connection, record_type)
    end,

    record_field_tree: lambda do |connection, **args|
      if (record_type = args&.[](:__parent_id)).presence
        ## Get "Contents" -- Record Fields
        call(:get_record_fields, connection, record_type).map do |option|
          [
            option[0], ## Label with record type
            [record_type, option[1]].join('.'), ## Value
            nil, ## Child Options
            false ## Is Not Parent Folder
          ]
        end
      else
        ## Get "Folders" -- Record Types
        record_types = call(:get_record_types, connection).map do |option|
          [
            option[0], ## Label
            option[1], ## Value
            nil,  ## Child Options
            true  ## Is Parent Folder
          ]
        end

        ## Drop the first, which will be '- None -'
        record_types.drop(1)
      end
    end
  },

  object_definitions: {

    field_value: {

      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'value',
            label: 'Value',
            type: 'string'
          },
          {
            name: 'text',
            label: 'Text',
            type: 'string',
            optional: true
          }
        ]
      end
    },

    export_id_option: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'export_id',
            label: 'ZAB API Export',
            hint: "Customize your request's response by providing a related ZAB API Export.
              This will return an additional 'results' property that will contain the export's results,
              filtered to your specific record.",
            pick_list: 'api_exports',
            control_type: :select,
            extends_schema: true,
            optional: true,
            sticky: true,
            toggle_hint: 'Select',
            toggle_field: {
              name: 'export_id',
              label: 'ZAB API Export',
              hint: 'Indicate the ZAB API Export ID configured in your environment that you would like to retrieve.',
              control_type: :string,
              extends_schema: true,
              change_on_blur: true,
              type: :string,
              toggle_hint: 'Export ID'
            }
          }
        ]
      end
    },

    external_references: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        [
          {
            name: 'external_references',
            label: 'External References',
            hint: "External References allow you to identify the value of a select field by an attribute field
              on it's corresponding record type. (Eg. configure an external reference so the 'customer' field
              can be identified by the external ID field of the customer, rather than the internal ID)",
            type: :array,
            of: :object,
            list_mode: 'static',
            item_label: 'External Reference',
            list_mode_toggle: false,
            properties: object_definitions['external_reference']
          }
        ]
      end
    },

    external_reference: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'field_id',
            label: 'Field ID',
            hint: "Select the field ID of the select field on the target record.
              (For Example, the 'customer' field on the 'contact'.)",
            type: :string,
            control_type: :select,
            optional: false,
            extends_schema: true,
            sticky: true,
            pick_list: 'record_fields',
            pick_list_params: {
              record_type: 'record_type'
            },
            toggle_hint: 'Select',
            toggle_field: {
              name: 'field_id',
              label: 'Field ID',
              type: :string,
              control_type: :text,
              optional: false,
              change_on_blur: true,
              extends_schema: true,
              toggle_hint: 'ID',
              hint: "Indicate the field ID of the select field on the target record.
                (For Example, the 'customer' field on the 'contact'.)"
            }
          },
          {
            name: 'related_field_id',
            label: 'Related Field ID',
            hint: "Select the related record type and the field ID which contains the identifying attribute.
              (Eg. Select 'Customer' then 'externalid', to identify the select field by the customer's externalid)",
            control_type: 'tree',
            optional: false,
            sticky: true,
            pick_list: 'record_field_tree',
            toggle_hint: 'Select',
            toggle_field: {
              name: 'related_field_id',
              label: 'Related Field ID',
              type: :string,
              control_type: :text,
              change_on_blur: true,
              extends_schema: true,
              optional: false,
              toggle_hint: 'ID',
              hint: 'Indicate the related record type and the field ID that contains the unique external reference.
                This should be joined together by a "." (Eg. "customer.externalid")'
            }
          }
        ]
      end
    },

    get_export_filters: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        hint = 'Indicate the record type of the target ZAB API Export which you would like to filter on.
         This is required in order to source the fields to filter below'

        [
          {
            name: 'record_type',
            label: 'Record Type',
            hint: hint,
            type: :string,
            control_type: :select,
            extends_schema: true,
            sticky: true,
            pick_list: 'record_types',
            toggle_hint: 'Select',
            toggle_field: {
              name: 'record_type',
              label: 'Record Type',
              hint: hint,
              control_type: :string,
              change_on_blur: true,
              extends_schema: true,
              type: :string,
              toggle_hint: 'ID'
            }
          },
          {
            name: 'filters',
            label: 'Filters',
            ngIf: 'input.dynamic_filters.record_type',
            type: :array,
            of: :object,
            properties: object_definitions['export_filter'],
            item_label: 'Filter',
            list_mode: 'static',
            list_mode_toggle: false
          }
        ]
      end
    },

    export_filter: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'field_id',
            label: 'Field ID',
            hint: 'Select the field you want to filter the ZAB API Export by.',
            type: :string,
            control_type: :select,
            optional: false,
            extends_schema: true,
            sticky: true,
            pick_list: 'record_fields',
            pick_list_params: {
              record_type: 'dynamic_filters.record_type'
            },
            toggle_hint: 'Select',
            toggle_field: {
              name: 'field_id',
              label: 'Field ID',
              type: :string,
              control_type: :text,
              optional: false,
              change_on_blur: true,
              extends_schema: true,
              toggle_hint: 'ID',
              hint: 'Indicate the specific field you want to filter by.
                You can join to another record for complex filtering by adding a dot (Eg. "customer.email").'
            }
          },
          {
            name: 'operator',
            label: 'Operator',
            hint: 'Select the Operator to identify the results by.',
            type: :string,
            control_type: :select,
            optional: false,
            sticky: true,
            default: 'is',
            pick_list: 'operators'
          },
          {
            name: 'value',
            label: 'Value',
            hint: 'Indicate the value you want to filter by',
            type: :string,
            optional: false,
            sticky: true
          },
          {
            name: 'type',
            label: 'Type',
            hint: "It is necessary to change this in scenarios where the filter data type is either a
              'Date' or 'Date/Time' field. Default behavior is used unless otherwise indicated.",
            type: :string,
            control_type: :select,
            optional: false,
            sticky: true,
            default: 'filter',
            pick_list: 'filter_types'
          }
        ]
      end
    },

    file_export_options: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        [
          {
            name: 'file_export_type',
            label: 'Export Type',
            hint: 'Select the type of file you would like to retrieve from NetSuite, either record PDF or record HTML.
              By default, the record PDF is returned.',
            control_type: :select,
            pick_list: 'file_export_type',
            default: 'recordpdf',
            sticky: true,
            optional: true
          },
          {
            name: 'file_compression_type',
            label: 'File Compression Type',
            hint: 'Select the compression type that you would like the file to be returned in.
              By default, the content is returned in a Base64 format.',
            control_type: :select,
            pick_list: 'file_compression_type',
            sticky: true,
            optional: true
          },
          {
            name: 'template_id',
            label: 'Template ID',
            hint: 'Provide a specific Template ID that you would like the record file to be formatted in.
              If the record type is not a transaction, this is required.',
            type: :integer,
            control_type: :integer,
            sticky: true,
            optional: call(:is_transaction_type, config_fields['record_type'])
          }
        ]
      end
    },

    automations_option: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        [
          {
            name: 'automations',
            label: 'Automations',
            hint: 'Select the ZAB Automation you would like to trigger upon completion of your request.
              Select multiple ZAB Automations to chain multiple automations together.',
            control_type: :multiselect,
            delimiter: ',',
            pick_list: 'automations',
            extends_schema: true,
            optional: config_fields.blank? ? false : true,
            sticky: true,
            toggle_hint: 'Select',
            toggle_field: {
              name: 'automations',
              label: 'Automations',
              type: :string,
              control_type: :text,
              change_on_blur: true,
              extends_schema: true,
              toggle_hint: 'ID',
              hint: 'Indicate the specific automation IDs you want to trigger upon completion of your request.
                For chained ZAB Automations, seperate each ID by a comma (Eg. "1,2,3,4").'
            }
          }
        ]
      end
    },

    post_input_options: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        [
          {
            name: 'options',
            label: 'Options',
            type: :object,
            properties: [
              object_definitions['export_id_option'],
              object_definitions['automations_option'],
              object_definitions['external_references']
            ].flatten
          }
        ]
      end
    },

    record_fields: {
      fields: lambda do |connection, config_fields, _object_definitions|
        record_type = config_fields['record_type'] || ''
        external_key = config_fields['external_key'] || ''
        options = config_fields['options'] || {}
        external_references = options['external_references'] || []

        response = call(:get_record_details, connection, record_type) || {}

        fields = response['fields'] || []
        sublists = response['sublists'] || []

        fields = [
          {
            name: 'record_fields',
            label: 'Fields',
            type: :object,
            properties: fields.map do |field|
              ## Always replace 'id' with 'internalid' because we want to use this property instead
              field['id'] = 'internalid' if field['id'] == 'id'

              is_external_reference = !external_references.find do |external_reference|
                external_reference['field_id'] == field['id']
              end.nil?

              is_external_key = field['id'] == external_key
              is_mandatory = is_external_key || is_external_reference

              call(:get_workato_field, field, is_mandatory)
            end
          }
        ]

        sublist_fields = sublists.map do |sublist|
          hint = sublist['recordType'] ? "<b>Related Record Type ID: </b>#{sublist['recordType']}" : null

          next unless sublist['fields'].length

          {
            name: sublist['id'],
            label: sublist['name'],
            hint: hint,
            type: :array,
            of: :object,
            list_mode: 'dynamic',
            item_label: sublist['name'] || sublist['id'],
            properties: sublist['fields'].map do |field|
              call(:get_workato_field, field, false)
            end
          }
        end

        unless sublist_fields.blank?
          fields.push({
                        name: 'sublist_fields',
                        label: 'Sublists',
                        type: :object,
                        properties: sublist_fields
                      })
        end

        fields
      end
    },

    post_response: {
      fields: lambda do |_connection, config_fields, object_definitions|
        fields = []
        options = config_fields['options'] || {}
        config_fields['record_fields'] || {}

        if config_fields['record_type']
          fields.push({
                        name: 'internalid',
                        label: 'Internal ID',
                        type: :integer
                      })
        end

        unless options['automations'].blank?
          fields.push({
                        name: 'reference_id',
                        label: 'Reference ID',
                        type: :integer
                      })
        end

        if options['export_id']
          response = object_definitions['get_response'] || {}

          index = response.find_index do |field|
            field['name'] == 'results'
          end

          fields.push(response[index])
        end

        fields
      end
    },

    post_batch_response: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'reference_id',
            label: 'Reference ID',
            type: :integer
          }
        ]
      end
    },

    get_file_response: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'name',
            label: 'File Name',
            type: :string
          },
          {
            name: 'description',
            label: 'Description',
            type: :string
          },
          {
            name: 'contents',
            label: 'File',
            type: :string
          }
        ]
      end
    },

    get_options_response: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'include_empty_properties',
            label: 'Include Empty Properties',
            hint: 'If true, properties/fields that have empty values will be included in the results',
            type: 'boolean',
            control_type: 'checkbox',
            extends_schema: true,
            sticky: true,
            optional: true
          },
          {
            name: 'text_always',
            label: 'Include Text Always',
            hint: 'If true, a text property will be returned for each attribute, even if it is the same as the value',
            type: 'boolean',
            control_type: 'checkbox',
            extends_schema: true,
            sticky: true,
            optional: true
          },
          {
            name: 'label_as_key',
            label: 'Use NetSuite Column Label as Result Key',
            hint: 'If true, the object keys will be the NetSuite Search Column Labels',
            default: true,
            type: 'boolean',
            control_type: 'checkbox',
            extends_schema: true,
            sticky: true,
            optional: true
          }
        ]
      end
    },

    get_options_request: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'return_all',
            label: 'Return All',
            hint: 'If true, the request will run un-paged. All results will be returned',
            type: 'boolean',
            default: 'false',
            control_type: 'checkbox',
            extends_schema: true,
            sticky: true,
            optional: true
          },
          {
            name: 'page_size',
            label: 'Page Size',
            hint: 'Indicate the maximum volume of results you would like returned between 5 and 1000 (Default is 1000)',
            ngIf: 'input.options.return_all == "false"',
            type: :integer,
            control_type: :integer,
            extends_schema: true,
            sticky: true,
            optional: true
          },
          {
            name: 'page_number',
            label: 'Page Number',
            hint: 'Specify a specific page number you would like received',
            ngIf: 'input.options.return_all == "false"',
            type: :integer,
            control_type: :integer,
            extends_schema: true,
            sticky: true,
            optional: true
          }
        ]
      end
    },

    get_response: {
      fields: lambda do |connection, config_fields, _object_definitions|
        options = config_fields['options'] || {}

        fields = [
          {
            name: 'page',
            label: 'Page',
            type: 'integer'
          },
          {
            name: 'total_pages',
            label: 'Total Pages',
            type: 'integer'
          },
          {
            name: 'total_results',
            label: 'Total Results',
            type: 'integer'
          },
          {
            name: 'results_returned',
            label: 'Results Returned',
            type: 'integer'
          }
        ]

        ## Get Export Metadata
        if config_fields['export_id'] || options['export_id']

          input = {
            'export_id' => config_fields['export_id'] || options['export_id'],
            'dynamic_filters' => config_fields['dynamic_filters'] || {},
            'options' => {
              ## Override options to limit size for performance of sample request
              'return_all' => false,
              'page_size' => 50,
              'label_as_key' => options['label_as_key'] || false,
              'include_empty_properties' => options['include_empty_properties'] || false,
              'text_always' => options['text_always'] || false
            }
          }

          ## Do API Call
          response = call(:get_export_id, connection, input)

          ## Parse Response
          columns = response['results'].first || {}
          record_fields = columns.map do |column_header, value|
            {
              name: column_header,
              type: :object,
              properties: value.map do |label, _field_value|
                { name: label }
              end
            }
          end

          fields.push({
                        name: 'results',
                        label: 'Results',
                        type: :array,
                        of: :object,
                        properties: record_fields
                      })
        end

        fields
      end
    },

    batch_response: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'status',
            label: 'Status',
            type: 'object',
            properties: [
              {
                name: 'id',
                type: 'ID'
              },
              {
                name: 'text',
                type: 'Text'
              }
            ]
          },
          {
            name: 'response',
            label: 'Response',
            type: 'object',
            properties: [
              {
                name: 'processed_count',
                type: 'integer'
              },
              {
                name: 'error_count',
                type: 'integer'
              },
              {
                name: 'results',
                type: 'array',
                of: 'object'
              },
              {
                name: 'errors',
                type: 'array',
                of: 'object'
              }
            ]
          }
        ]
      end
    }

  },

  methods: {

    post: lambda do |_connection, input, operation|
      ## Organize Options
      options = input['options'] || {}
      automations = options['automations'] || ''

      ## Organize Payload Shell
      payload = {
        operation: operation,
        recordType: input['record_type'],
        externalKey: options['external_key'],
        externalReferences: call(:get_external_references, options),
        export_id: options['export_id'],
        automations: automations.split(',')
      }.reject do |_, v|
        ## Remove empty params
        v.blank? || v.nil?
      end

      ## Parse for Bulk API
      if input['records']
        payload['records'] = input['records'].map do |record_fields|
          call(:parse_record, record_fields)
        end
      ## Parse for Singular Record Action
      elsif input['record_fields']
        payload['record'] = call(:parse_record, input)
      end

      ## Send Request and Handle Response
      post('', payload)
        .after_response do |code, body, headers|
          if !body['success'] || body['error']
            call(:validate_response, code, body, headers)
          else
            body
          end
        end
    end,

    get: lambda do |_connection, params|
      get('', params)
        .after_response do |code, body, headers|
          call(:validate_response, code, body, headers)
        end
    end,

    # Standardize how we parse errors for our requests
    validate_response: lambda do |_code, body, _headers|
      error_check = body.is_a?(Array) ? body[0] : body

      if !error_check['success'] || error_check['error']
        error_details = body['error'] || body
        error_details['name'].to_s || 'API_ERROR'
        error_details['message'].to_s || 'There was an error with your request.
          Please check the logs in Workato and NetSuite.'

        error_elements = [
          error_details['name'],
          error_details['message']
        ].compact.join(' : ')

        error(error_elements)
      else
        body
      end
    end,

    get_post_sample_response: lambda do |connection, input|
      result = {
        internalid: 101
      }

      options = input['options'] || {}

      if options['export_id']
        response = call(:get_export_id, connection, input)
        result['results'] = response['results'] || []
      end

      result['reference_id'] = 123 if options['automations']

      result
    end,

    get_export_id: lambda do |connection, input|
      options = input['options'] || {}
      parameters = call(:get_filter_parameters, input)

      params = parameters.merge({
        export_id: input['export_id'] || options['export_id'],
        internalid: input['internal_id'] || options['internal_id'],
        externalid: input['external_id'] || options['external_id']
      }.compact)

      call(:get, connection, params)
    end,

    get_filter_parameters: lambda do |input|
      parameters = {}
      options = input['options'] || {}
      dynamic_filters = input['dynamic_filters'] || {}
      filters = dynamic_filters['filters'] || []

      ## Normal Parameters
      options.map do |key, value|
        parameters[key] = value unless value.is_a?(Hash)
      end

      ## Dynamic Filter Parameters
      filters.map do |filter|
        parameter = [
          filter['type'],
          filter['operator'],
          filter['field_id']
        ].join('_')

        parameters[parameter] = filter['value']
      end

      parameters
    end,

    get_record_details: lambda do |connection, record_type|
      params = {
        get_record_details: true,
        record_type: record_type
      }

      call(:get, connection, params) unless record_type.blank?
    end,

    get_record_types: lambda do |connection|
      results = []
      params = {
        get_record_types: true
      }
      response = call(:get, connection, params) || {}
      record_types = response['results']

      record_types.each do |record_type_details|
        results.push(
          [
            # Picklist Name
            record_type_details['name'],
            # API Name
            record_type_details['scriptId']
          ]
        )
      end

      results
    end,

    get_record_fields: lambda do |connection, record_type|
      # We always want to start with this vs. the regular 'id' field
      results = [
        ['Internal ID', 'internalid']
      ]

      response = call(:get_record_details, connection, record_type) || {}
      response_fields = response['fields'] || []

      response_fields.each do |field_details|
        next unless field_details['id'] != 'id'

        results.push(
          [
            # Picklist Name
            field_details['label'],
            # API Name
            field_details['id']
          ]
        )
      end

      # Sort by label
      results.sort_by do |result|
        result[0]
      end
    end,

    get_field_type: lambda do |field_type|
      control_types = {
        'float' => 'number',
        'currency' => 'number',
        'integer' => 'integer',
        'checkbox' => 'checkbox',
        'select' => 'text',
        'text' => 'text',
        'textarea' => 'plain-text-area',
        'date' => 'date',
        'datetime' => 'date_time',
        'multiselect' => 'multi_select',
        'url' => 'url'
      }

      control_types[field_type]
    end,

    get_record_file: lambda do |connection, input|
      options = input['options'] || {}

      params = {
        record_type: input['record_type'],
        record_id: input['record_id'],
        file_export_type: options['file_export_type'],
        file_compression_type: options['file_compression_type'],
        template_id: options['template_id']
      }

      call(:get, connection, params)
    end,

    get_record_file_attachments: lambda do |connection, input|
      params = {
        record_type: input['record_type'],
        record_id: input['record_id'],
        file_export_type: 'recordattachments'
      }

      results = call(:get, connection, params)

      {
        files: results.map do |result|
          call(:get_file_result, result)
        end
      }
    end,

    get_file_result: lambda do |result|
      file = result['file']

      {
        name: file['name'],
        description: file['description'],
        contents: file['contents']
      }
    end,

    get_workato_field: lambda do |field, is_mandatory|
      control_type = call(:get_field_type, field['type'])
      field_id = field['id']
      is_select = field['type'] == 'select'
      is_custom = field_id.match?(/Acust/) && !field_id.match?(/zab_/) ## Only native and zab fields are not custom
      hint = "<b>Field ID: </b>#{field_id}"

      {
        name: field['id'],
        label: field['label'],
        hint: hint,
        ## We decided to not do mandatory field validation at the connector level
        ## because NetSuite or ZAB may auto-determine values the record via native UEs
        optional: !is_mandatory,
        custom: is_custom,
        control_type: is_select ? :integer : control_type,
        toggle_hint: is_select ? 'Value' : null,
        toggle_field: if is_select
                        {
                          name: is_select ? "#{field['id']}-text" : field['id'],
                          label: "#{field['label']} (in Text)",
                          type: :string,
                          control_type: :text,
                          toggle_hint: 'Text',
                          hint: "#{hint}.text"
                        }
                      else
                        null
                      end
      }
    end,

    get_external_references: lambda do |options|
      input = options['external_references'] || []

      ## Sort through each reference and format properly
      input.map do |reference|
        related_field_id = reference['related_field_id'] || ''
        related_attributes = related_field_id.split('.')

        {
          fieldId: reference['field_id'],
          relatedRecordType: related_attributes[0], # Related Record Type
          relatedFieldId: related_attributes[1] # Related Record Field
        }
      end
    end,

    parse_record: lambda do |input|
      sublists = input['sublist_fields'] || {}
      record_fields = input['record_fields'] || {}

      record = {
        internalid: input['internalid'] || ''
      }

      record_fields.each do |key, value|
        new_key = call(:parse_record_field_key, key)
        record[new_key] = value
      end

      sublists.each do |sublist_id, sublist_records|
        sublists[sublist_id] = sublist_records.map do |sublist_record_fields|
          sublist_record = {}
          sublist_record_fields.each do |key, value|
            new_key = call(:parse_record_field_key, key)
            sublist_record[new_key] = value
          end
          sublist_record
        end
      end

      {
        body: record,
        sublists: sublists
      }
    end,

    is_transaction_type: lambda do |record_type|
      transaction_types = %w[
        invoice
        cashsale
        salesorder
        creditmemo
        cashrefund
        vendorbill
        vendorcredit
        vendorpayment
        expensereport
        opportunity
        estimate
        returnauthorization
        purchaseorder
        customerdeposit
      ]

      transaction_types.include? record_type
    end,

    parse_record_field_key: lambda do |key|
      key_parts = key.split('-')

      is_text = key_parts[1] ? key_parts[1] == 'text' : false

      new_key = is_text ? "#{key_parts[0]}.text" : key_parts[0]

      new_key
    end
  }
}
