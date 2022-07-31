@AbapCatalog.sqlViewName: 'Z_CDS_VIEW_FLR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS'
define view Z_CDS_STICKET_SBOOK as select distinct from sbook as sbook
inner join spfli as _spfli
on sbook.connid  = _spfli.connid and sbook.passname <> ''
inner join scarr as _scarr
on _spfli.carrid  = _scarr.carrid

    {

    key sbook.carrid as Carrid,
    key sbook.connid as Connid,  
    key sbook.fldate as Fldate,
    key sbook.customid as Customid,
    sbook.passname as Passname,
    _scarr.carrname as Carrname,
    concat ( concat( _spfli.cityfrom, '-') , _spfli.cityto) as Route,
    
    case 
      when sbook.class='C' then 'Бизнес класс'
      when sbook.class='Y' then 'Эконом класс'
      when sbook.class='F' then 'Первый класс'
      else 'Не определён'      
    end as Class, 
    case
     when sbook.luggweight > 0 then 'Ручная кладь оплачена'
     else 'Без ручной клади'
     end as Luggweight,       
    case 
     when sbook.invoice ='X' and sbook.cancelled <> 'X'
     then  'Бронь оплачена'
     else 'Бронь не оплачена'
     end as Invoice
    
}   
