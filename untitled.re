/show email stats for past (\d*) (days|weeks)/
show email stats for past 5 days
show email stats for past 2 weeks

1.count = number of units - when
2.unit = days or weeks
==================================================================*
/show email (complaints|bounces|deliveries|stats) for (.+\@.+\.\w+) during past (\d*) (days|day|weeks|week)/
show email complaints for test@email.com during past 5 days
show email complaints for test@email.com during past 10 weeks
show email bounces for test@email.com during past 5 days
show email bounces for test@email.com during past 10 weeks
show email deliveries for test@email.com during past 5 days
show email deliveries for test@email.com during past 10 weeks
show email stats for test@email.com during past 3 days
show email stats for test@email.com during past 3 weeks

1. types = (complaints|bounces|deliveries|stats) - what
2. email = user email - who
3. count = number of unit - when
4. unit = days or weeks - when
==================================================================*
/show email (complaints|bounces|deliveries) for past (\d*) (days|day|weeks|week)/
show email bounces for past 3 days
show email deliveries for past 3 days
show email complaits for past 3 days
==================================================================
/show email (complaints|bounces|deliveries|stats) for ((1[0-2]|0?[1-9])\/(3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2})/
show email complaints for 02/13/2014
show email bounces for 02/13/2014
show email deliveries for 02/13/2014
show email stats for 02/13/2014
==================================================================
/show email (complaints|bounces|deliveries|stats) between ((?:1[0-2]|0?[1-9])\/(?:3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2}) (?:and|&|&amp) ((?:1[0-2]|0?[1-9])\/(?:3[01]|[12][0-9]|0?[1-9])\/(?:[0-9]{2})?[0-9]{2})/
show email complaints between 02/13/2014 and 02/13/2014
show email bounces between 02/13/2014 and 02/13/2014
show email deliveries between 02/13/2014 and 02/13/2014
show email stats between 02/13/2014 and 02/13/2014