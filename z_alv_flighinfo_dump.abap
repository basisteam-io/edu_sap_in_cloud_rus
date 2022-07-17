*---------------------------------------------------------------------*
* Report:  "Z_ALV_FLIGHTINFO"
* Author:  курс "УСТАНОВКА И ИЗУЧЕНИЕ SAP В ПОПУЛЯРНЫХ ОБЛАЧНЫХ СЕРВИСАХ", Gorbenko R.
* Date: 09/26/2021
*---------------------------------------------------------------------*
 REPORT z_alv_flightinfo.
 TYPES: BEGIN OF z_alv_flightinfo,
          passname TYPE sbook-passname,
        END OF z_alv_flightinfo.
 DATA: itab TYPE TABLE OF z_alv_flightinfo.
 DATA: counter TYPE i.
 FIELD-SYMBOLS:
          <fs_itab> LIKE LINE OF itab.
		  
		  
		  
* selection screen
* event object start-of-selection.

 START-OF-SELECTION.
   PERFORM get_data.
   PERFORM call_alv.
**********************************************************************
*      Form  get_data
*********************************************************************
   FORM get_data.
   
   counter= 1 DIV 0.
   
   SELECT  *
     INTO  CORRESPONDING FIELDS OF TABLE itab
     FROM  sbook AS sbook.
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
 xfc-reptext_ddic = 'Имя пассажира'.
 xfc-fieldname    = 'PASSNAME'.
 xfc-tabname      = 'ITAB'.
 xfc-outputlen    = '18'.
 APPEND xfc TO ifc.


* Call abap List Viewer (alv)
   CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
             i_callback_program      = repid
             it_fieldcat             = ifc
        TABLES
             t_outtab                = itab.
 ENDFORM.