000100181009      * Include the required LongRange and EZI definitions
000200150204
000300180927     H BNDDIR('LRNGSRV') DFTACTGRP(*no) ACTGRP(*caller)
000400150204     H BNDDIR('EZISERVICE')
000500181009
000600181202     F* Table is filled with data from Car Enter the File spec
000700181202     FCAR_SALES UF   E           K DISK    Rename (CAR_SALES:CARSALESr)
001200150204
001201181203     D CSNumber        S              9A    Inz('') Varying
001202181203     D CSNumberL       S             22A    Inz('') Varying
001203181203
001300150204      * Define an EZI table
001500181008     D Table           DS                  LikeDS(EZI_QTable) Inz(*LikeDS)
001501180927
001600150204      * Define the items to be put in the table
001601181202     D  IdNumberL      Ds                  LikeDS(EZI_Label)     Inz(*LikeDS)
001701181202     D  CompanyL       Ds                  LikeDS(EZI_Label)     Inz(*LikeDS)
001702181202     D  DateL          DS                  LikeDS(EZI_Label)     Inz(*LikeDS)
001703181202     D  ActualSalesL   DS                  LikeDS(EZI_Label)     Inz(*LikeDS)
001704181202     D  PrevForecastL  DS                  LikeDS(EZI_Label)     Inz(*LikeDS)
001705181202     D  CurrForecastL  DS                  LikeDS(EZI_Label)     Inz(*LikeDS)
002100150204
002500150204     D Local           Ds
002600150204     D   MainLoopCount...
002700150204     D                               10I00 Inz(0)
002800150204     D   Row                         10I00 Inz(0)
003300150204
003400150204      * Named constant with size of table
003500180927     DSampleEntries    C                   100
003501181012      /INCLUDE LRNGSOURCE,LRNGCOMMON
003502181012      * Standard include for EZI services
003503181012      /INCLUDE QRPGLESRC,EZISERVICE
003504181012      * Standard demonstration definitions and prototypes
003505181012      /INCLUDE SOURCEDEMO,DEMOCOMMON
003506181012      * Standard form view handler parameter list declaration
003507181012      /INCLUDE SOURCEDEMO,STDPARAMS
003600150204
004000150204      * Program mainline
004100181008        /free
005000181008          //Set up the messagebar and table
005100181011          Exsr Define_Form_View;
005200181011          Exsr Fill_Table;
005300150204
005400181008          // Loop until this program should not handle the request
005500181008          // enter loop start below
005600181008          DoU (RequestPROGRAM <> ProgramINFO.Name);
005700150204
005800181008            MainLoopCount += 1;
005900150204
006000181008            // Handle the user's requested action
006100150204
006200181011            Exsr HandleRequestedACTION;
006600150204
006700181008            // Send and receive the form view
006800150204
006900181008            LRNG_SendReceive((MainLoopCount > 1):RequestPROGRAM:RequestACTION);
007100181008          EndDo;
007200150204
007300181008          // Finished, so return control to driver.
007400181008          *InLR = True;
007500181008          Return;
007600150204
007700181008          // ---------------------------------------------------------------------
007800181008          // Handle the user's request received in variable RequestACTION
007900181008          // ---------------------------------------------------------------------
008000150204
008100181011          BegSr HandleRequestedACTION;
008200181008            Select;
008300150204
008400181008            // Handle a touch/click on a row in the table
008500181011            When (RequestACTION = 'SELECT');
008501181203              CSNumberL = EZI_QTable_GetCurrentRowID(Table);
008502181203                CSNumber = CSNumberL;
008504181203                SAVEDState.CurrentCONTACT = CSNumber;
008609181011              RequestACTION = 'DEFAULT';
008610181011              // Set the name of the program to call for Details Form View
008611181202              RequestPROGRAM = 'UPDTETABLE';
008612181011              // Call the LongRange API SwitchToFormView
008613181202              LRNG_SwitchToFormView('FormUpdateTable');
008614181011              *InLr = True;
008615181011              Return;
009300181008            EndSl;
009400181008          EndSr;
009500150204
009600181008          // ---------------------------------------------------------------------
009700181008          // Set up the message bar
009800181008          // ---------------------------------------------------------------------
009900181011          BegSr Define_Form_View;
009901181202            // Define the 5 columns to be used in the table
009902181202            IdNumberL.Label = 'Car ID';
009903181202            CompanyL.Label = 'Company';
009904181202            DateL.Label = 'Calendar';
009905181202            ActualSalesL.Label = 'Actual Sales';
009906181202            PrevForecastL.Label = 'Previous Forecast';
009907181202            CurrForecastL.Label = 'Current Forecast';
009908181202
009910181011            // Now define the table - done after setting up the column definitions
009911181011            Table.ParentGRow = 2;              // The grid row in this form view is 2
009912181011            Table.ParentGCol = 1;              // The grid column in this form view is 1
009914181202            Table.FillColumn = 1;              // The address column is to fill up all spare space
009915181202
009916181011            LRNG_SetProperties( '/Form.Grid.Col%1.Width:Fill'
009917181011                              : '/Form.Grid.Row%1.Height:Fill');
009918181202
009919181202            // set the background color
009920181202            LRNG_SetProperty('/Form.BackColor' : '&544d5b');
009921181011
009922181202            Table.Title      = 'Car Sale Profile';     // Title
009923181202            Table.TitleAlign = 'center';
009924181011            Table.HighlightCurrentRow = True;  // Highlights the current row
009925181011            Table.onRowClicked = 'SELECT';     // Signals when a row touched/clicked
009926181202            Table.IDColumn = 1;                // Column 1 (Name) identifies the
010400181008          EndSr;
010700150204
010800181008          // ---------------------------------------------------------------------
010900181008          // Define and fill table with test data
011000181008          // ---------------------------------------------------------------------
011100150204
011200181011          BegSr Fill_Table;
013000181008            // EZI_QTable_Define( remove the comment characters (//) and complete this
013100181008            EZI_QTable_Define ( Table
013101181202                            : IdNumberL
013102181202                            : CompanyL
013103181202                            : DateL
013104181202                            : PrevForecastL
013105181202                            : ActualSalesL
013108181202                            : CurrForecastL );
013700181008
014814181009            Row = 0;
014815181202            setll *START CAR_SALES;
014816181202            READ CAR_SALES;
014817181008            Dow (NOT %EOF);
014821181008              Row += 1;
014822181202              EZI_QTable_PutRow (Table
014823181202                : Row
014824181202                : %CHAR(CARID)
014825181202                : COMPANY
014826181202                : %CHAR(DATE)
014827181202                : %CHAR(ACTUA00001)
014828181202                : %CHAR(PREV_00001)
014829181202                : %CHAR(CURR_00001));
014835181202              Read CAR_SALES;
014836181008            EndDo;
015900181008          EndSr;
016000181008        /end-free
