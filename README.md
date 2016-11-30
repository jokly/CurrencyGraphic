## Requirements
1. [WWW::Mechanize](http://search.cpan.org/~oalders/WWW-Mechanize-1.83/lib/WWW/Mechanize.pm)
2. [GD::Graph](http://search.cpan.org/dist/GDGraph/Graph.pm)
3. [Date::Simple](http://search.cpan.org/~izut/Date-Simple-3.03/lib/Date/Simple.pm)
4. [HTML::TableExtract](http://search.cpan.org/dist/HTML-TableExtract/lib/HTML/TableExtract.pm)

## How to use
`$ perl curency.pm <id> <start_date> <end_date>`
* `<id>` - cite identifier
  1. cb - http://www.cbr.ru/currency_base/dynamics.aspx
  2. fin - http://www.finmarket.ru/currency/rates
  3. val - http://val.ru/valhistory.asp
* Date format - `YYYY-mm-dd`
  1. `<first_date>` - start date interval
  2. `<last_date>` - end date interval
