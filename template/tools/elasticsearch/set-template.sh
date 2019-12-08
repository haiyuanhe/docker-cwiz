#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$CURL -XPUT $ES_URL/_template/knowledgebase -d '
{
    "order" : 1,
    "template" : "knowledgebase",
    "settings" : {
      "index" : {
        "number_of_replicas" : "<:elasticsearch_replicas:>",
        "refresh_interval" : "20s"
      }
    }
}
'

echo

$CURL -XPUT $ES_URL/_template/logstash -d '
{
    "order" : 0,
    "template" : "*-logstash-*",
    "settings" : {
      "index" : {
        "number_of_replicas" : "<:elasticsearch_replicas:>",
        "refresh_interval" : "20s"
      }
    },
    "mappings" : {
      "_default_" : {
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match_mapping_type" : "string",
            "match" : "message"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match_mapping_type" : "string",
            "match" : "*"
          }
        } ],
        "_all" : {
          "omit_norms" : true,
          "enabled" : true
        },
        "properties" : {
          "@timestamp" : {
            "type" : "date"
          },
          "geoip" : {
            "dynamic" : true,
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "request_time" : {
            "type" : "float"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "@version" : {
            "index" : "not_analyzed",
            "type" : "string"
          },
          "host" : {
            "index" : "not_analyzed",
            "type" : "string"
          },
          "type" : {
            "index" : "not_analyzed",
            "type" : "string"
          },
          "metric_value" : {
            "type" : "float"
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "index" : "not_analyzed",
            "type" : "string"
          }
        }
      },
      "cws.log" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "docker" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "client" : {
            "type" : "double"
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "log" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "stream" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "time" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "mongodb" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "mysql" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "loglevel" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "nginx" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "city_name" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "continent_code" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "continent_name" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "country_iso_code" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              },
              "timezone" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "ip" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "method" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "nginx.access" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "city_name" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "continent_code" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "continent_name" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "country_iso_code" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              },
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              },
              "timezone" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "ip" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "method" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "nginx.error" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "pg_log" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      },
      "security" : {
        "_all" : {
          "enabled" : true,
          "omit_norms" : true
        },
        "dynamic_templates" : [ {
          "message_field" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string"
            },
            "match" : "message",
            "match_mapping_type" : "string"
          }
        }, {
          "string_fields" : {
            "mapping" : {
              "fielddata" : {
                "format" : "disabled"
              },
              "index" : "analyzed",
              "omit_norms" : true,
              "type" : "string",
              "fields" : {
                "raw" : {
                  "ignore_above" : 256,
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            },
            "match" : "*",
            "match_mapping_type" : "string"
          }
        } ],
        "properties" : {
          "@timestamp" : {
            "type" : "date",
            "format" : "strict_date_optional_time||epoch_millis"
          },
          "@version" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "beat" : {
            "properties" : {
              "version" : {
                "type" : "string",
                "norms" : {
                  "enabled" : false
                },
                "fielddata" : {
                  "format" : "disabled"
                },
                "fields" : {
                  "raw" : {
                    "type" : "string",
                    "index" : "not_analyzed",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "geoip" : {
            "dynamic" : "true",
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "float"
              }
            }
          },
          "host" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "input_type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "message" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            }
          },
          "metric_value" : {
            "type" : "float"
          },
          "offset" : {
            "type" : "double"
          },
          "orgid" : {
            "type" : "double"
          },
          "remote_ip" : {
            "type" : "ip"
          },
          "request_time" : {
            "type" : "float"
          },
          "source" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "sysid" : {
            "type" : "double"
          },
          "type" : {
            "type" : "string",
            "norms" : {
              "enabled" : false
            },
            "fielddata" : {
              "format" : "disabled"
            },
            "fields" : {
              "raw" : {
                "type" : "string",
                "index" : "not_analyzed",
                "ignore_above" : 256
              }
            }
          },
          "upstream_time" : {
            "type" : "float"
          },
          "uri" : {
            "type" : "string",
            "index" : "not_analyzed"
          }
        }
      }
    },
    "aliases" : { }
}
'

echo

exit 0
