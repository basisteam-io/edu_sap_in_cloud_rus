@AbapCatalog.sqlViewName: 'Z_CDS_VIEW_FLR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS'
define view Z_CDS_STICKET_SBOOK as select distinct from sbook as sbook
association [1..1] to sticket as _sticket
on sbook.bookid = _sticket.bookid

    {
    key sbook.bookid as Bookid,
    key _sticket.carrid as Carrid,
    key _sticket.connid as Connid,  
    key _sticket.fldate as Fldate,
    key _sticket.customid as Customid,
    sbook.passname as Passname,
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
     end as Invoice,
    
 _sticket 
    
}   
