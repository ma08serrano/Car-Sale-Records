000001181129     H BNDDIR('LRNGSRV') DFTACTGRP(*no) ACTGRP(*caller)                                             
000002181201     H BNDDIR('EZISERVICE')                                                                         
000017181129      * File declarations                                                                           
000018181129     FCARSALESD CF   E             WORKSTN                                                          
000019181201                                                                                                    
000020181201     F* Table is filled with data from   Customer Enter the File spec                               
000021181201     FCAR_SALES IF   E             Disk    Rename (CAR_SALES:CARSALESr)                             
000023181201                                                                                                    
000030181129      * Define workfields                                                                           
000031181129     D                 DS                                                                           
000032181129     D TotalEntries                  10i00                                                          
000034181129     D Index                         10i00                                                          
000035181129     D OddColumn                       n                                                            
000036181129     D outHTML                    65000a   Varying                                                  
000043181129      * Define the compile time array data                                                          
000044181129     DTableEntries     c                   8                                                        
000045181202     D IdNumber                       9s 0 Dim(TableEntries)                                        
000046181201     D Companies                      8a   Dim(TableEntries)                                        
000047181201     D Image                         32A   Dim(12)                                                  
000048181201     D Calendar                      10a   Dim(TableEntries)                                        
000049181201     D Actual                         2s 0 Dim(TableEntries)                                        
000050181201     D Previous                       2s 0 Dim(TableEntries)                                        
000051181201     D Current                        2s 0 Dim(TableEntries)                                        
000052181129      * Prototype for call to SALESCARA                                                             
000053181129     DCARSALESA        pr                  ExtPgm('CARSALESA')                                      
000054181129     D dentries                      10i 0                                                          
000055181202     D didnumber                      9s 0 Dim(TableEntries)                                        
000056181201     D dcompany                       8a   Dim(TableEntries)                                        
000057181129     D dcalendar                     10a   Dim(TableEntries)                                        
000058181201     D dactual                        2s 0 Dim(TableEntries)                                        
000059181201     D dprevious                      2s 0 Dim(TableEntries)                                        
000060181201     D dcurrent                       2s 0 Dim(TableEntries)                                        
000061181129     D outHTML                    65000a   Varying                                                  
000062181201                                                                                                    
000063181201     D Local           Ds                                                                           
000064181201     D                               10I00 Inz(0)                                                   
000065181201     D   Row                         10I00 Inz(0)                                                   
000066181201                                                                                                    
000067181129      * Standard include to bring in the external LRNG support function protypes                    
000068181129     D/INCLUDE LRNGSOURCE,LRNGCOMMON                                                                
000069181129      * Standard include to bring in the demonstration definitions                                  
000070181129     D/INCLUDE SOURCEDEMO,DEMOCOMMON                                                                
000071181129      * Standard paremeter list declaration                                                         
000072181129     D/INCLUDE SOURCEDEMO,STDPARAMS                                                                 
000073181129     D*                                                                                             
000074181129      /Free                                                                                         
000075181201        Exsr Setup_MyTable;                                                                         
000076181129        // Loop for as long as this program is handling the requested action                        
000077181129        DoU (RequestPROGRAM <> ProgramINFO.Name);                                                   
000078181129           // Handle the currently requested action                                                 
000079181129           Exsr HandleRequestedAction;                                                              
000080181129           If RequestPROGRAM = ProgramINFO.Name;                                                    
000081181129              // Display this programs FormView                                                     
000082181129              Exsr DisplayFormView;                                                                 
000083181129           Endif;                                                                                   
000084181129        Enddo;                                                                                      
000085181129        // Finished.                                                                                
000086181129        *InLR = *ON;                                                                                
000087181129        Return;                                                                                     
000088181129        // ----------------------------------------------------------------------                   
000089181129        Begsr HandleRequestedAction;                                                                
000090181129           IsNewForm = True;                                                                        
000091181129           Select;                                                                                  
000092181129              // User has requested to see RPG or DDS Code                                          
000093181129              // NOTE: This code would not be in a real application of course!                      
000094181129              When ( %Subst(RequestACTION:1:4) = 'SHOW');                                           
000095181129                 Exsr HandleAction_SHOWRPGorDDS;                                                    
000096181129              // User has requested to perform the DEFAULT action                                   
000097181129              Other;                                                                                
000098181129                 Exsr HandleAction_DEFAULT;                                                         
000099181129           EndSl;                                                                                   
000100181129        EndSr;                                                                                      
000101181129       // ----------------------------------------------------------------------                    
000102181129       Begsr DisplayFormView;                                                                       
000103181129          // Standard screen display logic                                                          
000104181129          If (NOT IsNewForm);                                                                       
000105181129              LRNG_SetSendChangesOnly();                                                            
000106181129          Endif;                                                                                    
000107181129          LRNG_Send();                                                                              
000108181129          EXFMT FormView;                                                                           
000109181129          LRNG_Receive();                                                                           
000110181129          LRNG_GetRequestedAction(RequestPROGRAM:RequestACTION);                                    
000111181129       EndSr;                                                                                       
000112181129       // ----------------------------------------------------------------------                    
000113181129       Begsr HandleAction_DEFAULT;                                                                  
000114181129          Exsr LoadTable;  //  Output the consolidated data into a table                            
000115181129          Exsr LoadChart;  //  Build chart from table data                                          
000116181129       EndSr;                                                                                       
000117181129       // ----------------------------------------------------------------------                    
000118181129       // Handle a SHOWRPG or SHOWDDS request.                                                      
000119181129       // NOTE: This subroutine would not be in a real application of course!                       
000120181129       // ----------------------------------------------------------------------                    
000121181129       Begsr HandleAction_SHOWRPGorDDS;                                                             
000122181129          DemoShowCode ( SystemInfo : RequestACTION                                                 
000123181129                         : ProgramINFO.Name : RequestWasHandled);                                   
000124181129          IsNewForm = false;                                                                        
000125181129       Endsr;                                                                                       
000126181202       // ----------------------------------------------------------------------                    
000127181202       BegSr Setup_MyTable;                                                                         
000128181202         Row = 0;                                                                                   
000129181202         Read CAR_SALES;                                                                            
000130181202         Dow (NOT %EOF);                                                                            
000131181202           Row += 1;                                                                                
000132181202           IdNumber(Row) = %DEC(CARID);                                                             
000133181202           Companies(Row) = COMPANY;                                                                
000134181202           Calendar(Row) = %CHAR(DATE);                                                             
000135181202           Actual(Row) = %DEC(ACTUA00001);                                                          
000136181202           Previous(Row) = %DEC(PREV_00001);                                                        
000137181202           Current(Row) = %DEC(CURR_00001);                                                         
000138181202                                                                                                    
000139181202           Read CAR_SALES;                                                                          
000140181202         ENDDO;                                                                                     
000141181202       ENDSR;                                                                                       
000150181129       // ----------------------------------------------------------------------                    
000151181129       Begsr LoadChart;                                                                             
000152181129          // Build the required Google Chart HTML via call to SALESCARA                             
000153181201          TotalEntries = Row;                                                                       
000154181202          CARSALESA (TotalEntries : IdNumber : Companies : Calendar : Actual                        
000155181129            : Previous : Current : outHTML);                                                        
000156181129          // Put the resulting HTML string into the WEB view                                        
000157181129          LRNG_SetProperty('/Form.Fields.CHART.HtmlString' : outHTML);                              
000158181129       EndSr;                                                                                       
000159181129       // ----------------------------------------------------------------------                    
000160181129       Begsr LoadTable;                                                                             
000161181129          // Load up the table of company details shown on bottom of form                           
000162181129          OddColumn = False;                                                                        
000163181201          for Index = 1 to Row;                                                                     
000164181129            // Alternate odd and even tabel row background colors                                   
000165181129            OddColumn = NOT(OddColumn);                                                             
000166181129            // Set up to insert to ROW%N in the specified table                                     
000167181129             LRNG_Using('/Form.Fields.TABLE.ROW%'+%char(Index));                                    
000168181129            // Set the alternating backgroud colors for the table row                               
000169181129            If (OddColumn);                                                                         
000170181129               LRNG_SetProperty('BackColor':'&2c2a2e');                                             
000171181129            Endif;                                                                                  
000172181201            LRNG_AssignStrToProp( Image(Index):'IMAGECOL.resource');                                
000173181201            LRNG_AssignStrToProp( Companies(Index):'CARSALECOMPANY.Value');                         
000174181201            LRNG_AssignStrToProp( Calendar(Index):'CARSALECALENDAR.Value');                         
000175181201            LRNG_AssignStrToProp( %editc(Actual(Index):'4'):                                        
000176181201              'CARSALEACTUAL.Value');                                                               
000177181201            LRNG_AssignStrToProp( %editc(Previous(Index):'4'):                                      
000178181201              'CARSALEPRE.Value');                                                                  
000179181201            LRNG_AssignStrToProp( %editc(Current(Index):'4'):                                       
000180181201              'CARSALECUR.Value');                                                                  
000183181129         Endfor;                                                                                    
000184181129       EndSr;                                                                                       
000201181129      /end-free                                                                                     
000202181130                                                                                                    
