*---------------------------------------------------------------------*
* Report:  "Z_ALV_FLIGHTINFO"
* Author:  курс "УСТАНОВКА И ИЗУЧЕНИЕ SAP В ПОПУЛЯРНЫХ ОБЛАЧНЫХ СЕРВИСАХ", Gorbenko R.
* Date: 09/26/2021
*---------------------------------------------------------------------*
 REPORT z_alv_flightinfo.



 TYPES: BEGIN OF z_alv_flightinfo,
          bookid              TYPE sticket-bookid,
          carrid              TYPE sticket-carrid,
          connid              TYPE sticket-connid,
          fldate              TYPE sticket-fldate,
          customid            TYPE sticket-customid,
          passname            TYPE sbook-passname,
          class               TYPE sbook-class,
          class_text(25)      TYPE c,
          luggweight          TYPE sbook-luggweight,
          luggweight_text(25) TYPE c,
          invoice             TYPE sbook-invoice,
          cancelled           TYPE sbook-cancelled,
          invoice_text(20)    TYPE c,
        END OF z_alv_flightinfo.

 DATA:
   ls_sticket TYPE sticket,
   ls_sbook   TYPE sbook,
   itab       TYPE TABLE OF z_alv_flightinfo,
   itab_main  TYPE TABLE OF z_alv_flightinfo,
   wa         TYPE   z_alv_flightinfo,
   wa_main    TYPE   z_alv_flightinfo.


 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
   SELECTION-SCREEN COMMENT /1(79) o_text1.
   SELECT-OPTIONS: s_carrid FOR ls_sticket-carrid.
   SELECTION-SCREEN COMMENT /1(79) o_text2.
   SELECT-OPTIONS: s_connid FOR ls_sticket-connid.
   SELECTION-SCREEN COMMENT /1(79) o_text3.
   SELECT-OPTIONS: s_fldate FOR ls_sticket-fldate.
 SELECTION-SCREEN END OF BLOCK b1.


 INITIALIZATION.
   t1 = 'Задайте параметры рейса:'.
   o_text1 = 'Авиакомпания:'.
   o_text2 = 'Рейс по маршруту:'.
   o_text3 = 'Дата рейса:'.

* selection screen
* event object start-of-selection.

 START-OF-SELECTION.
   PERFORM get_data.
   PERFORM call_alv.
**********************************************************************
*      Form  get_data
*********************************************************************
 FORM get_data.
   SELECT *
     INTO  CORRESPONDING FIELDS OF TABLE @itab
     FROM  ( sbook AS sbook
           INNER JOIN sticket AS sticket ON sticket~customid = sbook~customid AND sticket~connid = sbook~connid AND sticket~fldate = sbook~fldate AND sticket~carrid = sbook~carrid
         )
     WHERE sticket~carrid = @s_carrid-low AND sticket~connid = @s_connid-low AND sticket~fldate = @s_fldate-low AND sbook~invoice = 'X' AND  sbook~cancelled <> 'X' AND passname <> ''.

   SORT itab BY bookid.

   DELETE ADJACENT DUPLICATES
   FROM itab COMPARING bookid.

   LOOP AT itab INTO wa.
     wa_main-bookid = wa-bookid.
     wa_main-passname = wa-passname.
     CASE wa-class.
       WHEN 'C'. wa_main-class_text = 'Бизнес класс'.
       WHEN 'Y'. wa_main-class_text = 'Эконом класс'.
       WHEN 'F'. wa_main-class_text = 'Первый класс'.
     ENDCASE.

     IF wa-luggweight > 0.
       wa_main-luggweight_text = 'Ручная кладь оплачена'.
     ELSE.
       wa_main-luggweight_text = 'Без ручной клади'.
     ENDIF.

     IF wa-invoice EQ 'X' AND wa-cancelled NE 'X'.
       wa_main-invoice_text = 'Бронь оплачена'.
     ELSE.
       wa_main-invoice_text = 'Бронь не оплачена'.
     ENDIF.
     APPEND wa_main TO itab_main.
     CLEAR wa_main.
     CLEAR wa.
   ENDLOOP.
 ENDFORM.

************************************************************************
*  call_alv
************************************************************************
 FORM call_alv.
   DATA: ifc TYPE slis_t_fieldcat_alv.
   DATA: xfc TYPE slis_fieldcat_alv.
*system variable that stores the current PROGRAM name
   DATA: repid TYPE sy-repid.
   repid = sy-repid.
   CLEAR xfc.
   REFRESH ifc.
   repid = sy-repid.

   xfc-reptext_ddic = 'Номер заказа'.
   xfc-fieldname    = 'BOOKID'.
   xfc-tabname      = 'ITAB_MAIN'.
   xfc-outputlen    = '8'.
   APPEND xfc TO ifc.
   CLEAR xfc.
   xfc-reptext_ddic = 'Имя пассажира'.
   xfc-fieldname    = 'PASSNAME'.
   xfc-tabname      = 'ITAB_MAIN'.
   xfc-outputlen    = '35'.
   APPEND xfc TO ifc.
   CLEAR xfc.
   xfc-reptext_ddic = 'Класс в салоне'.
   xfc-fieldname    = 'CLASS_TEXT'.
   xfc-tabname      = 'ITAB_MAIN'.
   xfc-outputlen    = '25'.
   APPEND xfc TO ifc.
   CLEAR xfc.
   xfc-reptext_ddic = 'Ручная кладь'.
   xfc-fieldname    = 'LUGGWEIGHT_TEXT'.
   xfc-tabname      = 'ITAB_MAIN'.
   xfc-outputlen    = '25'.
   APPEND xfc TO ifc.
   xfc-reptext_ddic = 'Статус брони'.
   xfc-fieldname    = 'INVOICE_TEXT'.
   xfc-tabname      = 'ITAB_MAIN'.
   xfc-outputlen    = '25'.
   APPEND xfc TO ifc.

* Call abap List Viewer (alv)
   CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
       i_callback_program = repid
       it_fieldcat        = ifc
     TABLES
       t_outtab           = itab_main.
 ENDFORM.
