val init : id -> (* id for player container *)
           float -> (* offset value *)
           (float -> transaction unit) -> (* set function *)
           url -> (* video url *)
           url -> (* audio url *)
           transaction unit
