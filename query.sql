Select
	-- Unique Claim Identifier
	Wc.ClaimID,
	Wc.ClaimCodeDWH,
	
	-- test for rejection flag, 1 is rejected, 0 is accepted, NULL is not yet accepted/rejected
	-- Need to know what each ClaimStatus means, so we can have accepted/rejected -> training, others -> predictions
	(Case
		When Len(Trim(Wc.RejectionCode)) > 1 Then 1  -- if a rejection code then a rejected claim
		When Wc.ClaimStatus In ('C', 'F', 'Q', 'U', 'V', 'Y', 'Z') Then 0  -- need here a list of statuses that mean a claim is processed
		Else NULL  -- all other claims go to NULL (meaning not yet rejected/accepted)
	End) as RejectedFlag,
	
	Wc.ClaimStatus,
	
	-- Other Claim Info: Date, Mileage
	Wc.DefectDate,
	Wc.KmChassis,
	Wc.ClaimSort,
	Wc.WarrantyCategory,
	Wc.PartMountDate,
	Wc.DriveLineYN,
	
	-- Rejection Info
	(Case
		When Len(Trim(Wc.RejectionCode)) > 1 Then Wc.RejectionCode
		Else NULL
	End) as RejectionCode,
	(Case
		When Len(Trim(Rc.Description)) > 1 Then Rc.Description
		When Len(Trim(Wc.RejectionCode)) <= 1 Then NULL
		Else 'Other'
	End) as RejectionDesc,
	
	-- Claim Origin
	Co.ClaimOrigin,
	(Case
		When Len(Trim(Co.ServiceProductDescr)) > 1 Then Co.ServiceProductDescr
		Else 'Other'
	End) as ClaimOriginDesc,
	Co.ServiceProductAbbr,
	Co.ServiceProductSort,
	
	-- Dealer Info & Text Narrative
	Wt.TextDD as DealerText,
	Dl.DealerName,
	Dl.DealerCity,
	Dl.CountryCode as DealerCountry,
	-- Dl.Status as DealerStatus,
	Dl.CategoryName as DealerCategoryName,
	
	-- Causal Part: Number, Description, Supplier
	(Case
		When Len(Trim(Wc.CausalPart)) > 1 Then Wc.CausalPart
		Else 'No Causal Part On Claim'
	End) as CausalPart,
	(Case
		When Len(Trim(Cp.PartDesc)) > 1 Then Cp.PartDesc
		When Len(Trim(Wc.CausalPart)) <= 1 Then NULL
		Else 'Other'
	End) as CausalPartDesc,
	(Case
		When Len(Trim(Cp.PartSupplier)) > 1 Then Cp.PartSupplier
		When Len(Trim(Wc.CausalPart)) <= 1 Then NULL
		Else 'Other'
	End) as CausalPartSupplier,
	
	-- Defect & Component Info: Code, Group, Class
	Wc.DefectCode,
	Cg.ComponentSubGroupNr as DefectGroup,
	(Case
		When Len(Trim(Cg.ComponentSubGroupDescr)) > 1 Then Cg.ComponentSubGroupDescr
		Else 'Other'
	End) as DefectDesc,
	(Case
		When Len(Trim(Oc.ObjectDescription)) > 1 Then Oc.ObjectDescription
		Else 'Other'
	End) as Component,
	(Case
		When Len(Trim(Oc.ComponentGroupDescription)) > 1 Then Oc.ComponentGroupDescription
		Else 'Other'
	End) as ComponentGroup,
	(Case
		When Len(Trim(Oc.PartClassDescription)) > 1 Then Oc.PartClassDescription
		Else 'Other'
	End) as ComponentClass,
	(Case
		When Len(Trim(Oc.PartSubClassDescription)) > 1 Then Oc.PartSubClassDescription
		Else 'Other'
	End) as ComponentSubClass,
	
	-- Chassis Info: Customer, Dates
	Cs.ChassisNr as ChassisNumber,
	Cu.CustomerName,
	Cs.ProductionDate,
	Cs.DeliveryDateDealer as DeliveryDateToDealer,
	Cs.DeliveryDate as DeliveryDateToCustomer,
	Cs.GearboxType,
	Cs.RetarderType,
	Cs.MotorNr,
	Cs.MotorNrLeyl,
	
	-- Model Type Info: Including Product Range, Axle Configuration, and if Bodied
	Wc.ClaimModel as Model,  -- 'FA LF260I16 535'
	SubString(Pr.ProductRange, 1, 2) as ModelFamily,  -- 'LF'
	Pr.ProductRange as ModelRange,  -- 'LF46'
	Pr.RangeName as ModelCategory,  -- 'LIGHT'
	Pr.PlantName as ModelPlant,  -- 'LTM'
	En.EngineDescr as ModelEngine,  -- 'PX-7'
	En.EnginePowerDescr as ModelEnginePower,  -- '260'
	Cn.ApplicationName as ModelApplication,  -- 'Rigid'
	Cn.ConfigurationCode as ModelConfig,  -- 'FA'
	Ac.AxleConfigurationDescr as ModelAxleDesc,  -- '4X2'
	Ac.NrOfAxles as ModelAxles,  -- '2'
	Cl.ClassificationDescr as ModelClass,  -- '14-16T'
	(Case
		When Trim(Lower(Bd.BodyDescr)) = 'body' Then 'Body'
		Else 'No Body'
	End) as BodyDesc,
	
	-- Claim Totals: Amount Claimed, Hours Claimed, and # Items on Claim
	Nvl(Ch.ArticleClaimedDN_DTNV, 0)
		+ Nvl(Ch.LabourClaimedDN_DTNV, 0)
		+ Nvl(Ch.MiscClaimedDN_DTNV, 0)
	as TotalClaimAmount,
	Ch.ArticleClaimedDN_DTNV as TotalPartClaim,
	Ch.LabourClaimedDN_DTNV as TotalLabourClaim,
	Ch.MiscClaimedDN_DTNV as TotalMiscClaim,
	Ch.LandedCost,
	Ch.HandlingCost,
	Ch.HoursClaimed as TotalLabourHours,
	
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 0
		When Len(Trim(Cd.Artnr2)) <= 1 Then 1
		When Len(Trim(Cd.Artnr3)) <= 1 Then 2
		When Len(Trim(Cd.Artnr4)) <= 1 Then 3
		When Len(Trim(Cd.Artnr5)) <= 1 Then 4
		Else 5
	End) as PartClaimCount,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 0
		When Len(Trim(Cd.LabDescr2)) <= 1 Then 1
		When Len(Trim(Cd.LabDescr3)) <= 1 Then 2
		When Len(Trim(Cd.LabDescr4)) <= 1 Then 3
		When Len(Trim(Cd.LabDescr5)) <= 1 Then 4
		Else 5
	End) as LabourItemCount,
	
	-- Top 5 Claimed Parts: Each has Amount, Part Number, Description, Supplier
	Cd.AmountClaimedArtnr1 as PartClaimAmount1,
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 'No Parts On Claim'
		Else Cd.Artnr1
	End) as Part1,
	(Case
		When Len(Trim(Cd.ArtDescr1)) > 1 Then Cd.ArtDescr1
		When Len(Trim(Cd.Artnr1)) <= 1 Then NULL
		Else 'Other'
	End) as PartDesc1,
	(Case
		When Len(Trim(P1.PartSupplier)) > 1 Then P1.PartSupplier
		When Len(Trim(Cd.Artnr1)) <= 1 Then NULL
		Else 'Other'
	End) as PartSupplier1,
	
	Cd.AmountClaimedArtnr2 as PartClaimAmount2,
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 'No Parts On Claim'
		When Len(Trim(Cd.Artnr2)) <= 1 Then 'One Part On Claim'
		Else Cd.Artnr2
	End) as Part2,
	(Case
		When Len(Trim(Cd.ArtDescr2)) > 1 Then Cd.ArtDescr2
		When Len(Trim(Cd.Artnr2)) <= 1 Then NULL
		Else 'Other'
	End) as PartDesc2,
	(Case
		When Len(Trim(P2.PartSupplier)) > 1 Then P2.PartSupplier
		When Len(Trim(Cd.Artnr2)) <= 1 Then NULL
		Else 'Other'
	End) as PartSupplier2,

	Cd.AmountClaimedArtnr3 as PartClaimAmount3,
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 'No Parts On Claim'
		When Len(Trim(Cd.Artnr2)) <= 1 Then 'One Part On Claim'
		When Len(Trim(Cd.Artnr3)) <= 1 Then 'Two Parts On Claim'
		Else Cd.Artnr3
	End) as Part3,
	(Case
		When Len(Trim(Cd.ArtDescr3)) > 1 Then Cd.ArtDescr3
		When Len(Trim(Cd.Artnr3)) <= 1 Then NULL
		Else 'Other'
	End) as PartDesc3,
	(Case
		When Len(Trim(P3.PartSupplier)) > 1 Then P3.PartSupplier
		When Len(Trim(Cd.Artnr3)) <= 1 Then NULL
		Else 'Other'
	End) as PartSupplier3,

	Cd.AmountClaimedArtnr4 as PartClaimAmount4,
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 'No Parts On Claim'
		When Len(Trim(Cd.Artnr2)) <= 1 Then 'One Part On Claim'
		When Len(Trim(Cd.Artnr3)) <= 1 Then 'Two Parts On Claim'
		When Len(Trim(Cd.Artnr4)) <= 1 Then 'Three Parts On Claim'
		Else Cd.Artnr4
	End) as Part4,
	(Case
		When Len(Trim(Cd.ArtDescr4)) > 1 Then Cd.ArtDescr4
		When Len(Trim(Cd.Artnr4)) <= 1 Then NULL
		Else 'Other'
	End) as PartDesc4,
	(Case
		When Len(Trim(P4.PartSupplier)) > 1 Then P4.PartSupplier
		When Len(Trim(Cd.Artnr4)) <= 1 Then NULL
		Else 'Other'
	End) as PartSupplier4,
	
	Cd.AmountClaimedArtnr5 as PartClaimAmount5,
	(Case
		When Len(Trim(Cd.Artnr1)) <= 1 Then 'No Parts On Claim'
		When Len(Trim(Cd.Artnr2)) <= 1 Then 'One Part On Claim'
		When Len(Trim(Cd.Artnr3)) <= 1 Then 'Two Parts On Claim'
		When Len(Trim(Cd.Artnr4)) <= 1 Then 'Three Parts On Claim'
		When Len(Trim(Cd.Artnr5)) <= 1 Then 'Four Parts On Claim'
		Else Cd.Artnr5
	End) as Part5,
	(Case
		When Len(Trim(Cd.ArtDescr5)) > 1 Then Cd.ArtDescr5
		When Len(Trim(Cd.Artnr5)) <= 1 Then NULL
		Else 'Other'
	End) as PartDesc5,
	(Case
		When Len(Trim(P5.PartSupplier)) > 1 Then P5.PartSupplier
		When Len(Trim(Cd.Artnr5)) <= 1 Then NULL
		Else 'Other'
	End) as PartSupplier5,
	
	-- Top 5 Claimed Labour Items: Each has Hours, Description, Type, Component Group & Class
	Cd.QuantityClaimedLabourcode1 as LabourHours1,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 'No Labour Items On Claim'
		Else Cd.LabDescr1
	End) as LabourDesc1,
	Jc1.Jobtype as LabourType1,
	(Case
		When Len(Trim(Lo1.ComponentGroupDescription)) > 1 Then Lo1.ComponentGroupDescription
		When Len(Trim(Cd.LabDescr1)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentGroup1,
	(Case
		When Len(Trim(Lo1.PartClassDescription)) > 1 Then Lo1.PartClassDescription
		When Len(Trim(Cd.LabDescr1)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentClass1,
	(Case
		When Len(Trim(Lo1.PartSubClassDescription)) > 1 Then Lo1.PartSubClassDescription
		When Len(Trim(Cd.LabDescr1)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentSubClass1,
	
	Cd.QuantityClaimedLabourcode2 as LabourHours2,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 'No Labour Items On Claim'
		When Len(Trim(Cd.LabDescr2)) <= 1 Then 'One Labour Item On Claim'
		Else Cd.LabDescr2
	End) as LabourDesc2,
	Jc2.Jobtype as LabourType2,
	(Case
		When Len(Trim(Lo2.ComponentGroupDescription)) > 1 Then Lo2.ComponentGroupDescription
		When Len(Trim(Cd.LabDescr2)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentGroup2,
	(Case
		When Len(Trim(Lo2.PartClassDescription)) > 1 Then Lo2.PartClassDescription
		When Len(Trim(Cd.LabDescr2)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentClass2,
	(Case
		When Len(Trim(Lo2.PartSubClassDescription)) > 1 Then Lo2.PartSubClassDescription
		When Len(Trim(Cd.LabDescr2)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentSubClass2,
	
	Cd.QuantityClaimedLabourcode3 as LabourHours3,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 'No Labour Items On Claim'
		When Len(Trim(Cd.LabDescr2)) <= 1 Then 'One Labour Item On Claim'
		When Len(Trim(Cd.LabDescr3)) <= 1 Then 'Two Labour Items On Claim'
		Else Cd.LabDescr3
	End) as LabourDesc3,
	Jc3.Jobtype as LabourType3,
	(Case
		When Len(Trim(Lo3.ComponentGroupDescription)) > 1 Then Lo3.ComponentGroupDescription
		When Len(Trim(Cd.LabDescr3)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentGroup3,
	(Case
		When Len(Trim(Lo3.PartClassDescription)) > 1 Then Lo3.PartClassDescription
		When Len(Trim(Cd.LabDescr3)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentClass3,
	(Case
		When Len(Trim(Lo3.PartSubClassDescription)) > 1 Then Lo3.PartSubClassDescription
		When Len(Trim(Cd.LabDescr3)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentSubClass3,
	
	Cd.QuantityClaimedLabourcode4 as LabourHours4,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 'No Labour Items On Claim'
		When Len(Trim(Cd.LabDescr2)) <= 1 Then 'One Labour Item On Claim'
		When Len(Trim(Cd.LabDescr3)) <= 1 Then 'Two Labour Items On Claim'
		When Len(Trim(Cd.LabDescr4)) <= 1 Then 'Three Labour Items On Claim'
		Else Cd.LabDescr3
	End) as LabourDesc4,
	Jc4.Jobtype as LabourType4,
	(Case
		When Len(Trim(Lo4.ComponentGroupDescription)) > 1 Then Lo4.ComponentGroupDescription
		When Len(Trim(Cd.LabDescr4)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentGroup4,
	(Case
		When Len(Trim(Lo4.PartClassDescription)) > 1 Then Lo4.PartClassDescription
		When Len(Trim(Cd.LabDescr4)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentClass4,
	(Case
		When Len(Trim(Lo4.PartSubClassDescription)) > 1 Then Lo4.PartSubClassDescription
		When Len(Trim(Cd.LabDescr4)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentSubClass4,
	
	Cd.QuantityClaimedLabourcode5 as LabourHours5,
	(Case
		When Len(Trim(Cd.LabDescr1)) <= 1 Then 'No Labour Items On Claim'
		When Len(Trim(Cd.LabDescr2)) <= 1 Then 'One Labour Item On Claim'
		When Len(Trim(Cd.LabDescr3)) <= 1 Then 'Two Labour Items On Claim'
		When Len(Trim(Cd.LabDescr4)) <= 1 Then 'Three Labour Items On Claim'
		When Len(Trim(Cd.LabDescr5)) <= 1 Then 'Four Labour Items On Claim'
		Else Cd.LabDescr5
	End) as LabourDesc5,
	Jc5.Jobtype as LabourType5,
	(Case
		When Len(Trim(Lo5.ComponentGroupDescription)) > 1 Then Lo5.ComponentGroupDescription
		When Len(Trim(Cd.LabDescr5)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentGroup5,
	(Case
		When Len(Trim(Lo5.PartClassDescription)) > 1 Then Lo5.PartClassDescription
		When Len(Trim(Cd.LabDescr5)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentClass5,
	(Case
		When Len(Trim(Lo5.PartSubClassDescription)) > 1 Then Lo5.PartSubClassDescription
		When Len(Trim(Cd.LabDescr5)) <= 1 Then NULL
		Else 'Other'
	End) as LabourComponentSubClass5
	
From
	-- Base table for Warranty Claims
	Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Claim Wc
	
	-- Joins to dim_Warr_Claim
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_fact_Warr_ClaimHeader Ch  -- for the claim headers: totals and other IDs to link (Origin, Dealer, Component Group, Type, Chassis)
		On Ch.ClaimID = Wc.ClaimID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_aggr_Warr_ClaimDetails Cd  -- for the top 5 claim item breakdown: part numbers and labour
		On Cd.ClaimID = Wc.ClaimID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_aggr_Warr_Text Wt  -- for the dealer text narrative
		On Wt.ClaimID = Wc.ClaimID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_RejectionCode Rc  -- for the description of the rejection code
		On Rc.RejectionCode = Wc.RejectionCode
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Oc  -- for the defect component group & class
		On Oc.ObjectCodeID = Wc.ObjectCodeID
	
	-- Joins to fact_Warr_ClaimHeader
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ClaimOrigin Co  -- for the claim origin/service product
		On Co.ClaimOriginID = Ch.ClaimOriginID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Dealer Dl  -- for the dealer info
		On Dl.DealerID = Ch.DealerID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ComponentGroup Cg  -- for the defect group and description
		On Cg.ComponentGroupID = Ch.ComponentGroupID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Type Ty  -- for the joins on the model info (Product Range, Engine, Axles & Configuration, Classification, Body)
		On Ty.TypeID = Ch.TypeID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Chassis Cs  -- for the claim vehicle info (e.g. chassis number, dates)
		On Cs.ChassisID = Ch.ChassisID
	
	-- Joins to dim_Warr_Type
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ProductRange Pr  -- for the model range info
		On Pr.ProductRangeID = Ty.ProductRangeID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Engine En  -- for the engine description and power
		On En.EngineID = Ty.EngineID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_AxleConfiguration Ac  -- for the number of axles and configuration (e.g. 4X2)
		On Ac.AxleConfigurationID = Ty.AxleConfigurationID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Configuration Cn  -- for the axle configuration code and rigid/tractor application (e.g. FA - Rigid)
		On Cn.ConfigurationID = Ty.ConfigurationID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Classification Cl  -- for the model class (e.g. 14-16T) if available
		On Cl.ClassificationID = Ty.ClassificationID
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Body Bd  -- for the flag if a vehicle is bodied
		On Bd.BodyID = Ty.BodyID
	
	-- Joins to dim_Warr_Chassis
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_Customer Cu  -- for the customer name
		On Cu.CustomerID = Cs.CustomerID
	
	-- Joins for Part Info (Causal and Claimed), grouped by to ensure unique part numbers & filtered on non-empty part number
	Left Join (	Select ArticleNumber Part, Min(ClassDescription) PartDesc, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) Cp  -- for the causal part description/supplier on the claim (if given)
		On Cp.Part = Wc.CausalPart
	Left Join (	Select ArticleNumber Part, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) P1  -- for the supplier of the 1st part on the claim
		On P1.Part = Cd.Artnr1
	Left Join (	Select ArticleNumber Part, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) P2  -- for the supplier of the 2nd part on the claim
		On P2.Part = Cd.Artnr2
	Left Join (	Select ArticleNumber Part, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) P3  -- for the supplier of the 3rd part on the claim
		On P3.Part = Cd.Artnr3
	Left Join (	Select ArticleNumber Part, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) P4  -- for the supplier of the 4th part on the claim
		On P4.Part = Cd.Artnr4
	Left Join (	Select ArticleNumber Part, Min(LongName) PartSupplier
				From Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_vw_Warr_Article_Descriptions Where ArticleNumber != ' ' Group By ArticleNumber) P5  -- for the supplier of the 5th part on the claim
		On P5.Part = Cd.Artnr5
	
	-- Joins for Labour Type/Component Info: first the Job Code then the Object Code
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_JobCode Jc1  -- for the job type of the 1st labour item on the claim
		On Jc1.Jobcode = Cd.Labourcode1
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Lo1  -- for the component group & class of the 1st labour item on the claim
		On Lo1.ObjectCode = Jc1.ObjectCode
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_JobCode Jc2  -- for the job type of the 2nd labour item on the claim
		On Jc2.Jobcode = Cd.Labourcode2
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Lo2  -- for the component group & class of the 2nd labour item on the claim
		On Lo2.ObjectCode = Jc2.ObjectCode
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_JobCode Jc3  -- for the job type of the 3rd labour item on the claim
		On Jc3.Jobcode = Cd.Labourcode3
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Lo3  -- for the component group & class of the 3rd labour item on the claim
		On Lo3.ObjectCode = Jc3.ObjectCode
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_JobCode Jc4  -- for the job type of the 4th labour item on the claim
		On Jc4.Jobcode = Cd.Labourcode4
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Lo4  -- for the component group & class of the 4th labour item on the claim
		On Lo4.ObjectCode = Jc4.ObjectCode
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_JobCode Jc5  -- for the job type of the 5th labour item on the claim
		On Jc5.Jobcode = Cd.Labourcode5
	Left Join Daf_db.CA_Analytics_DWH.DWH_Datamart_dbo_dim_Warr_ObjectCode Lo5  -- for the component group & class of the 5th labour item on the claim
		On Lo5.ObjectCode = Jc5.ObjectCode
	
Where 1=1
	And Wc.PartType = 'O'  -- original equipment part claims only
	And Left(Wc.ClaimModel, 1) = 'F'  -- all models we need start with the axle config code (e.g. FA, FT, FAT) so we can restrict on the first character is F
	And Wc.DefectDate >= '2024-10-01'  -- filter on when to start the data period, based on the defect date
;