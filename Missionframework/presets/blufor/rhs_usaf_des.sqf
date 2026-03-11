/*
    Needed Mods:
    - RHS USAF

    Optional Mods:
    - F-15C
    - F/A-18
    - USAF Main Pack
    - USAF Fighters Pack
    - USAF Utility Pack
*/

/*
    --- Support classnames ---
    Each of these should be unique.
    The same classnames for different purposes may cause various unpredictable issues with player actions.
    Or not, just don't try!
*/
FOB_typename = "Land_Cargo_HQ_V3_F";                                    // This is the main FOB HQ building.
FOB_box_typename = "B_Slingload_01_Cargo_F";                            // This is the FOB as a container.
FOB_truck_typename = "rhsusf_M1078A1P2_B_D_CP_fmtv_usarmy";             // This is the FOB as a vehicle.
Arsenal_typename = "B_supplyCrate_F";                                   // This is the virtual arsenal as portable supply crates.
Respawn_truck_typename = "rhsusf_M1230a1_usarmy_d";    // This is the mobile respawn (and medical) truck.
huron_typename = "RHS_CH_47F_light";                                          // This is Spartan 01, a multipurpose mobile respawn as a helicopter.
crewman_classname = "rhsusf_army_ocp_combatcrewman";                    // This defines the crew for vehicles.
pilot_classname = "rhsusf_army_ocp_helipilot";                          // This defines the pilot for helicopters.
KP_liberation_little_bird_classname = "HH60G_cargo";                  // These are the little birds which spawn on the Freedom or at Chimera base.
KP_liberation_boat_classname = "B_Boat_Transport_01_F";                 // These are the boats which spawn at the stern of the Freedom.
KP_liberation_truck_classname = "rhsusf_M977A4_BKIT_usarmy_d";          // These are the trucks which are used in the logistic convoy system.
KP_liberation_small_storage_building = "ContainmentArea_02_sand_F";     // A small storage area for resources.
KP_liberation_large_storage_building = "ContainmentArea_01_sand_F";     // A large storage area for resources.
KP_liberation_recycle_building = "Land_RepairDepot_01_tan_F";           // The building defined to unlock FOB recycling functionality.
KP_liberation_air_vehicle_building = "B_Radar_System_01_F";             // The building defined to unlock FOB air vehicle functionality.
KP_liberation_heli_slot_building = "Land_HelipadSquare_F";              // The helipad used to increase the GLOBAL rotary-wing cap.
KP_liberation_plane_slot_building = "SatelliteAntenna_01_Sand_F";             // The hangar used to increase the GLOBAL fixed-wing cap.
KP_liberation_supply_crate = "CargoNet_01_box_F";                       // This defines the supply crates, as in resources.
KP_liberation_ammo_crate = "B_CargoNet_01_ammo_F";                      // This defines the ammunition crates.
KP_liberation_fuel_crate = "CargoNet_01_barrels_F";                     // This defines the fuel crates.

/*
    --- Friendly classnames ---
    Each array below represents one of the 7 pages within the build menu.
    Format: ["vehicle_classname",supplies,ammunition,fuel],
    Example: ["B_APC_Tracked_01_AA_F",300,150,150],
    The above example is the NATO IFV-6a Cheetah, it costs 300 supplies, 150 ammunition and 150 fuel to build.
    IMPORTANT: The last element inside each array must have no comma at the end!
*/
infantry_units = [
    ["rhsusf_army_ocp_riflemanl",15,0,0],                               // Rifleman (Light)
    ["rhsusf_army_ocp_rifleman",20,0,0],                                // Rifleman
    ["rhsusf_army_ocp_riflemanat",30,0,0],                              // Rifleman (AT)
    ["rhsusf_army_ocp_grenadier",25,0,0],                               // Grenadier
    ["rhsusf_army_ocp_autorifleman",25,0,0],                            // Autorifleman
    ["rhsusf_army_ocp_machinegunner",35,0,0],                           // Heavygunner
    ["rhsusf_army_ocp_marksman",30,0,0],                                // Marksman
    ["rhsusf_army_ocp_javelin",50,10,0],                                // AT Specialist
    ["rhsusf_army_ocp_aa",50,10,0],                                     // AA Specialist
    ["rhsusf_army_ocp_medic",30,0,0],                                   // Combat Life Saver
    ["rhsusf_army_ocp_engineer",30,0,0],                                // Engineer
    ["rhsusf_army_ocp_explosives",30,0,0],                              // Explosives Specialist
    ["rhsusf_usmc_recon_marpat_d_rifleman",20,0,0],                     // Recon Rifleman
    ["rhsusf_usmc_recon_marpat_d_rifleman_at",30,0,0],                  // Recon Rifleman (AT)
    ["rhsusf_usmc_recon_marpat_d_machinegunner_m249",25,0,0],           // Recon Autorifleman
    ["rhsusf_usmc_recon_marpat_d_machinegunner",35,0,0],                // Recon Machine Gunner
    ["rhsusf_usmc_recon_marpat_d_marksman",30,0,0],                     // Recon Marksman
    ["rhsusf_usmc_recon_marpat_d_sniper_M107",70,5,0],                  // Recon Sniper (M107)
    ["rhsusf_army_ocp_sniper",70,5,0],                                  // Sniper
    ["rhsusf_army_ocp_sniper_m107",70,5,0],                             // Sniper (M107)
    ["rhsusf_army_ocp_sniper_m24sws",70,5,0],                           // Sniper (M24 SWS)
    ["rhsusf_army_ocp_combatcrewman",10,0,0],                           // Crewman
    ["rhsusf_army_ocp_rifleman_101st",20,0,0],                          // Para Trooper
    ["rhsusf_army_ocp_helicrew",10,0,0],                                // Helicopter Crew
    ["rhsusf_army_ocp_helipilot",10,0,0],                               // Helicopter Pilot
    ["rhsusf_airforce_jetpilot",10,0,0]                                 // Pilot
];

light_vehicles = [
	["B_Quadbike_01_F",20,0,20],
	["NDS_6x6_ATV_MIL2",30,0,20],
	["NDS_6x6_ATV_MIL2_LR",30,0,30],
	["rhsusf_mrzr4_d",30,0,30],
	["UK3CB_BAF_LandRover_Soft_Sand_A",50,0,40],
	["UK3CB_BAF_LandRover_Soft_FFR_Sand_A",50,0,40],
	["UK3CB_BAF_LandRover_Hard_Sand_A",50,0,40],
	["UK3CB_BAF_LandRover_Snatch_Sand_A",50,0,40],
	["UK3CB_BAF_LandRover_Amb_Sand_A",75,0,40],
	["UK3CB_BAF_MAN_HX60_Cargo_Sand_A",50,0,50],
	["UK3CB_BAF_MAN_HX58_Cargo_Sand_A",80,0,50],
	["rhsusf_M1083A1P2_D_flatbed_fmtv_usarmy",50,0,50],
	["rhsusf_M1083A1P2_D_fmtv_usarmy",50,0,50],
	["rhsusf_M1078A1P2_D_flatbed_fmtv_usarmy",50,0,50],
	["rhsusf_M1084A1P2_D_fmtv_usarmy",50,0,50],
	["rhsusf_M1078A1P2_D_fmtv_usarmy",50,0,50],
	["rhsusf_M1078A1P2_B_D_flatbed_fmtv_usarmy",50,0,50],
	["rhsusf_M1078A1P2_B_D_fmtv_usarmy",50,0,50],
	["rhsusf_M1083A1P2_B_M2_D_flatbed_fmtv_usarmy",50,0,50],
	["rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy",50,50,50],
	["rhsusf_M1084A1R_SOV_M2_D_fmtv_socom",50,50,50],
	["rhsusf_M1084A1P2_B_M2_D_fmtv_usarmy",50,50,50],
	["rhsusf_M142_usarmy_D",50,150,50],
	["rhsusf_M1078A1R_SOV_M2_D_fmtv_socom",50,50,50],
	["rhsusf_M977A4_usarmy_d",80,0,50],
	["rhsusf_M977A4_BKIT_M2_usarmy_d",80,50,50],
	["B_LSV_01_unarmed_F",50,0,50],
	["B_LSV_01_armed_F",100,100,50],
	["UK3CB_BAF_LandRover_WMIK_GPMG_Sand_A",75,30,50],
	["UK3CB_BAF_LandRover_WMIK_HMG_Sand_A",75,50,50],
	["UK3CB_BAF_LandRover_WMIK_GMG_Sand_A",75,75,50],
	["UK3CB_BAF_LandRover_WMIK_Milan_FFR_Sand_A",75,100,50],
	["UK3CB_BAF_Coyote_Passenger_L111A1_D2",100,100,75],
	["UK3CB_BAF_Coyote_Logistics_L111A1_D2",100,100,75],
	["UK3CB_BAF_Coyote_Passenger_L134A1_D",100,150,75],
	["UK3CB_BAF_Coyote_Logistics_L134A1_D2",100,150,75],
	["rhsusf_m998_d_4dr",30,0,40],
	["rhsusf_m998_d_4dr_halftop",50,0,40],
	["rhsusf_m998_d_2dr_halftop",50,0,40],
	["rhsusf_m1025_d_m2",50,50,40],
	["rhsusf_m1025_d_Mk19",50,75,40],
	["rhsusf_m1045_d",50,100,40],
	["rhsusf_m1151_m240_v1_usarmy_d",75,30,40],
	["rhsusf_m1151_m2_v1_usarmy_d",75,50,40],
	["rhsusf_m1151_m2_lras3_v1_usarmy_d",75,50,40],
	["rhsusf_m1151_mk19_v2_usarmy_d",75,75,40],
	["rhsusf_m1151_m2crows_usarmy_d",80,50,40],
	["rhsusf_m1151_mk19crows_usarmy_d",80,75,40],
	["rhsusf_m1165a1_gmv_m2_m240_socom_d",80,100,40],
	["rhsusf_m1165a1_gmv_m134d_m240_socom_d",80,120,40],
	["rhsusf_m1165a1_gmv_mk19_m240_socom_d",80,150,40],
	["UK3CB_BAF_Husky_Passenger_GPMG_Sand",50,40,50],
	["UK3CB_BAF_Husky_Logistics_GPMG_Sand",50,40,50],
	["UK3CB_BAF_Husky_Passenger_HMG_Sand",50,50,50],
	["UK3CB_BAF_Husky_Logistics_HMG_Sand",50,50,50],
	["UK3CB_BAF_Husky_Passenger_GMG_Sand",50,75,50],
	["UK3CB_BAF_Husky_Logistics_GMG_Sand",50,75,50],
	["UK3CB_BAF_Panther_GPMG_Sand_A",75,50,50],
	["rhsusf_m1240a1_usarmy_d",80,0,50],
	["rhsusf_m1240a1_m240_usarmy_d",80,40,50],
	["rhsusf_m1240a1_m2_usarmy_d",80,50,50],
	["rhsusf_m1240a1_mk19_usarmy_d",80,75,50],
	["rhsusf_m1240a1_m2crows_usarmy_d",80,50,50],
	["rhsusf_m1240a1_mk19crows_usarmy_d",80,75,50],
	["rhsusf_m1245_m2crows_socom_d",80,50,50],
	["rhsusf_m1245_mk19crows_socom_d",80,75,50],
	["rhsusf_CGRCAT1A2_usmc_d",80,0,60],
	["rhsusf_CGRCAT1A2_M2_usmc_d",80,50,60],
	["rhsusf_M1238A1_socom_d",100,0,80],
	["rhsusf_M1238A1_M2_socom_d",100,50,80],
	["rhsusf_M1238A1_Mk19_socom_d",100,75,80],
	["rhsusf_M1232_usarmy_d",120,0,100],
	["rhsusf_M1232_M2_usarmy_d",120,50,100],
	["rhsusf_M1232_MK19_usarmy_d",120,75,100],
	["rhsusf_M1237_M2_usarmy_d",120,50,100],
	["rhsusf_M1237_M2_usarmy_d",120,50,100],
	["rhsusf_M1232_MK19_usarmy_d",120,75,100],
	["rhsusf_M1239_socom_d",100,0,100],
	["rhsusf_M1239_M2_socom_d",100,50,100],
	["rhsusf_M1239_MK19_socom_d",100,75,100],
	["rhsusf_M1239_M2_Deploy_socom_d",100,50,100],
	["rhsusf_M1239_MK19_Deploy_socom_d",100,75,100],
	["rhsusf_M1220_usarmy_d",120,0,100],
	["rhsusf_M1220_M153_M2_usarmy_d",120,50,100],
	["rhsusf_M1220_M153_MK19_usarmy_d",120,75,100],
	["rhsusf_M1220_M2_usarmy_d",120,50,100],
	["rhsusf_M1220_MK19_usarmy_d",120,75,100],
	["rhsusf_M1230_M2_usarmy_d",130,50,100],
	["rhsusf_M1230_MK19_usarmy_d",130,75,100],
	["B_Lifeboat",20,0,20],
	["B_Boat_Transport_01_F",20,0,20],
	["UK3CB_BAF_RHIB_GPMG",50,40,50],
	["UK3CB_BAF_RHIB_HMG",50,50,50],
	["B_Boat_Armed_01_minigun_F",50,100,50],
	["rhsusf_mkvsoc",100,150,100]
];

heavy_vehicles = [
	["rhsusf_m113d_usarmy_medical",100,0,100],
	["rhsusf_m113d_usarmy_M240",100,50,100],
	["rhsusf_m113d_usarmy",100,60,100],
	["rhsusf_m113d_usarmy_MK19",100,75,100],
	["rhsusf_M1117_D",100,100,100],
	["rhsusf_stryker_m1126_m2_d",120,50,100],
	["rhsusf_stryker_m1126_mk19_d",120,75,100],
	["rhsusf_stryker_m1127_m2_d",120,50,100],
	["rhsusf_stryker_m1132_m2_np_d",120,50,100],
	["rhsusf_stryker_m1132_m2_d",125,50,100],
	["rhsusf_stryker_m1134_d",120,100,100],
	["UK3CB_BAF_FV432_Mk3_GPMG_Sand",100,50,100],
	["UK3CB_BAF_FV432_Mk3_RWS_Sand",100,75,100],
	["B_APC_Tracked_01_rcws_F",120,50,100],
	["B_APC_Tracked_01_CRV_F",150,50,100],
	["UK3CB_BAF_Warrior_A3_D",150,100,100],
	["UK3CB_BAF_Warrior_A3_D_Cage_Camo",150,100,100],
	["RHS_M2A2",150,100,100],
	["RHS_M2A2_BUSKI",180,100,100],
	["RHS_M2A3",150,100,100],
	["RHS_M2A3_BUSKI",180,100,100],
	["RHS_M2A3_BUSKIII",200,100,100],
	["RHS_M6",150,100,100],
	["B_AFV_Wheeled_01_cannon_F",200,150,100],
	["B_AFV_Wheeled_01_up_cannon_F",200,150,100],
	["B_APC_Tracked_01_AA_F",200,150,100],
	["B_MBT_01_mlrs_F",200,200,100],
	["B_MBT_01_arty_F",200,400,100],
	["rhsusf_m109d_usarmy",200,400,100],
	["B_MBT_01_cannon_F",200,200,200],
	["B_MBT_01_TUSK_F",200,200,200],
	["rhsusf_m1a1aimd_usarmy",200,200,200],
	["rhsusf_m1a2sep1d_usarmy",200,200,200],
	["rhsusf_m1a2sep2d_usarmy",200,200,200],
	["rhsusf_m1a1aim_tuski_d",300,250,200],
	["rhsusf_m1a2sep1tuskid_usarmy",300,250,200],
	["rhsusf_m1a2sep1tuskiid_usarmy",350,250,200]
];

air_vehicles = [
	[huron_typename,500,50,500],
	["RHS_MELB_H6M",200,0,200],
	["RHS_MELB_MH6M",200,0,200],
	["RHS_MELB_AH6M",200,200,200],
	["rhs_uh1h_hidf",250,100,200],
	["rhs_uh1h_hidf_gunship",250,200,200],
	["RHS_UH60M_ESSS2_d",300,0,200],
	["RHS_UH60M_ESSS_d",300,0,200],
	["RHS_UH60M_MEV_d",300,0,200],
	["RHS_UH60M_d",300,150,200],
	["HH60G_base",300,0,200],
	["UK3CB_BAF_Apache_AH1_CAS",500,400,400],
	["UK3CB_BAF_Apache_AH1_DynamicLoadout",500,450,400],
	["UK3CB_BAF_Apache_AH1_AT",500,500,400],
	["RHS_AH64D",500,450,400],
	["UK3CB_BAF_Merlin_HC3_18_GPMG",350,200,300],
	["RHS_CH_47F_10",400,100,300],
	["RHS_CH_47F_10_cargo",400,100,300],
	["rhsgred_hidf_cessna_o3a",200,0,200],
	["RHSGREF_A29B_HIDF",200,100,200],
	["RHS_AN2_B",300,0,200],
	["rhs_l159_cdf_b_CDF",400,200,200],
	["B_Plane_CAS_01_dynamicLoadout_F",500,250,500],
	["RHS_A10",500,400,500],
	["USAF_A10",500,400,500],
	["USAF_F22_EWP_AA",450,400,500],
	["USAF_F22_EWP_AG",450,400,500],
	["USAF_F22_Heavy",450,450,500],
	["B_Plane_Fighter_01_F",450,450,500],
	["USAF_F35A_LIGHT",450,300,400],
	["USAF_F35A",450,450,400],
	["B_T_VTOL_01_Vehicle_F_Kimi",500,0,200],
	["B_T_VTOL_01_INFANTRY_F",500,0,200],
	["B_T_VTOL_01_ARMED_F",500,400,200],
	["USAF_C130J",500,0,300],
	["USAF_C130J_Cargo",500,0,300],
	["USAF_AC130U",2000,2000,2000],
	["usaf_kc135",500,0,800],
	["USAF_C17",500,0,500],
	["USAF_RQ4A",200,0,200],
	["B_UAV_05_F",200,0,200],
	["B_UAV_02_dynamicLoadout_F",200,200,200],
	["USAF_MQ9",500,200,200],
	["UK3CB_BAF_MQ9_Reaper",500,200,200]
];

static_vehicles = [
	["B_UAV_01_F",10,0,0],
	["B_UAV_06_F",10,0,0],
	["B_UGV_02_Demining_F",20,20,0],
	["B_UGV_01_rcws_F",100,100,0],
	["UK3CB_BAF_LandRover_Panama_Sand_A",50,0,50],
	["RHS_M2StaticMG_MiniTripod_D",20,20,0],
	["RHS_M2StaticMG_D",20,20,0],
	["RHS_MK19_TriPod_D",20,40,0],
	["RHS_TOW_TriPod_D",20,50,0],
	["B_Mortar_01_F",20,40,0],
	["UK3CB_BAF_Static_L16_Deployed",20,40,0],
	["RHS_M252_D",20,40,0],
	["RHS_M119_D",20,50,0],
	["RHS_Stinger_AA_pod_D",50,50,0],
	["B_SAM_System_03_F",50,50,0],
	["B_Radar_System_01_F",50,0,0]
];

buildings = [
    ["Land_Cargo_House_V3_F",0,0,0],
    ["Land_Cargo_Patrol_V3_F",0,0,0],
    ["Land_Cargo_Tower_V3_F",0,0,0],
	["Land_Dome_Big_F",0,0,0],
	["Land_Dome_Small_F",0,0,0],
	["cwa_MASH",0,0,0],
	["cwa_ACamp",0,0,0],
	["cwa_CampEast",0,0,0],
	["cwa_Camp",0,0,0],
	["Land_CanvasCover_02_F",0,0,0],
	["Land_CanvasCover_01_F",0,0,0],
	["Land_MedicalTent_01_MTP_closed_F",0,0,0],
	["Land_MedicalTent_01_NATO_generic_inner_F",0,0,0],
	["Land_Barrack2",0,0,0],
    ["Flag_NATO_F",0,0,0],
    ["Flag_US_F",0,0,0],
    ["BWA3_Flag_Ger_F",0,0,0],
    ["Flag_UK_F",0,0,0],
    ["Flag_White_F",0,0,0],
    ["Land_Medevac_house_V1_F",0,0,0],
    ["Land_Medevac_HQ_V1_F",0,0,0],
    ["Flag_RedCrystal_F",0,0,0],
    ["CamoNet_BLUFOR_F",0,0,0],
    ["CamoNet_BLUFOR_open_F",0,0,0],
    ["CamoNet_BLUFOR_big_F",0,0,0],
    ["Land_PortableLight_single_F",0,0,0],
    ["Land_PortableLight_double_F",0,0,0],
    ["Land_LampSolar_F",0,0,0],
    ["Land_LampHalogen_F",0,0,0],
    ["Land_LampStreet_small_F",0,0,0],
    ["Land_LampAirport_F",0,0,0],
    ["Land_HelipadCircle_F",0,0,0],                                     // Strictly aesthetic - as in it does not increase helicopter cap!
    ["Land_HelipadRescue_F",0,0,0],                                     // Strictly aesthetic - as in it does not increase helicopter cap!
    ["PortableHelipadLight_01_blue_F",0,0,0],
    ["PortableHelipadLight_01_green_F",0,0,0],
    ["PortableHelipadLight_01_red_F",0,0,0],
	["USMC_WarfareBUAVterminal",0,0,0],
	["USMC_WarfareBVehicleServicePoint",0,0,0],
	["cwa_Crawling",0,0,0],
	["cwa_ExcerciseTrack",0,0,0],
	["cwa_ExcerciseTrack2",0,0,0],
	["cwa_ExcerciseTrack3",0,0,0],
	["Land_DragonsTeeth_01_4x2_new_F",0,0,0],
	["Land_vodni_vez",0,0,0],
	["Land_Ind_IlluminantTower",0,0,0],
	["Land_Shooting_range",0,0,0],
	["ShootingRange_ACR",0,0,0],
	["ShedSmall",0,0,0],
	["Land_Strazni_vez",0,0,0],
	["Land_Hlaska",0,0,0],
	["Land_RoadBarrier_01_F",0,0,0],
    ["Land_CampingChair_V1_F",0,0,0],
    ["Land_CampingChair_V2_F",0,0,0],
    ["Land_CampingTable_F",0,0,0],
	["Land_WoodenTable_large_F",0,0,0],
	["Land_WoodenTable_02_large_F",0,0,0],
	["Land_TablePlastic_01_F",0,0,0],
	["Land_ChairPlastic_F",0,0,0],
    ["MapBoard_altis_F",0,0,0],
    ["MapBoard_stratis_F",0,0,0],
    ["MapBoard_seismic_F",0,0,0],
	["Land_MapBoard_Enoch_F",0,0,0],
	["MapBoard_seismic_F",0,0,0],
    ["Land_Pallet_MilBoxes_F",0,0,0],
    ["Land_PaperBox_open_empty_F",0,0,0],
    ["Land_PaperBox_open_full_F",0,0,0],
    ["Land_PaperBox_closed_F",0,0,0],
    ["Land_DieselGroundPowerUnit_01_F",0,0,0],
    ["Land_ToolTrolley_02_F",0,0,0],
    ["Land_WeldingTrolley_01_F",0,0,0],
    ["Land_Workbench_01_F",0,0,0],
    ["Land_GasTank_01_blue_F",0,0,0],
    ["Land_GasTank_01_khaki_F",0,0,0],
    ["Land_GasTank_01_yellow_F",0,0,0],
    ["Land_GasTank_02_F",0,0,0],
	["Hedgehog_EP1",0,0,0],
	["Land_jezekbeton",0,0,0],
	["Land_PaperBox_closed_F",0,0,0],
	["Land_PaperBox_open_full_F",0,0,0],
	["Land_Pallet_MilBoxes_F",0,0,0],
	["Land_PortableDesk_01_sand_F",0,0,0],
	["Land_PortableCabinet_01_closed_sand_F",0,0,0],
	["Land_PortableCabinet_01_7drawers_sand_F",0,0,0],
	["Land_PortableCabinet_01_lid_sand_F",0,0,0],
	["Land_PortableCabinet_01_4drawers_sand_F",0,0,0],
	["Land_PortableCabinet_01_bookcase_sand_F",0,0,0],
	["Land_DeskChair_01_sand_F",0,0,0],
	["rhsgref_serhat_radar_d",0,0,0],
	["StorageBladder_01_fuel_sand_F",0,0,0],
	["StorageBladder_02_water_sand_F",0,0,0],
	["Land_RefuelingHose_01_F",0,0,0],
    ["Land_BarrelWater_F",0,0,0],
    ["Land_BarrelWater_grey_F",0,0,0],
    ["Land_WaterBarrel_F",0,0,0],
    ["Land_WaterTank_F",0,0,0],
    ["Land_BagFence_Round_F",0,0,0],
    ["Land_BagFence_Short_F",0,0,0],
    ["Land_BagFence_Long_F",0,0,0],
    ["Land_BagFence_Corner_F",0,0,0],
    ["Land_BagFence_End_F",0,0,0],
    ["Land_BagBunker_Small_F",0,0,0],
    ["Land_BagBunker_Large_F",0,0,0],
    ["Land_BagBunker_Tower_F",0,0,0],
    ["Land_HBarrier_1_F",0,0,0],
    ["Land_HBarrier_3_F",0,0,0],
    ["Land_HBarrier_5_F",0,0,0],
    ["Land_HBarrier_Big_F",0,0,0],
    ["Land_HBarrierWall4_F",0,0,0],
    ["Land_HBarrierWall6_F",0,0,0],
    ["Land_HBarrierWall_corner_F",0,0,0],
    ["Land_HBarrierWall_corridor_F",0,0,0],
    ["Land_HBarrierTower_F",0,0,0],
    ["Land_CncBarrierMedium_F",0,0,0],
    ["Land_CncBarrierMedium4_F",0,0,0],
    ["Land_Concrete_SmallWall_4m_F",0,0,0],
    ["Land_Concrete_SmallWall_8m_F",0,0,0],
    ["Land_CncShelter_F",0,0,0],
    ["Land_CncWall1_F",0,0,0],
    ["Land_CncWall4_F",0,0,0],
    ["Land_Sign_WarningMilitaryArea_F",0,0,0],
    ["Land_Sign_WarningMilAreaSmall_F",0,0,0],
    ["Land_Sign_WarningMilitaryVehicles_F",0,0,0],
    ["Land_Razorwire_F",0,0,0],
	["CUP_A2_Road_PMC_dirt2_11000",0,0,0],
	["CUP_A2_Road_PMC_dirt2_12",0,0,0],
	["CUP_A2_Road_PMC_dirt2_1575",0,0,0],
	["CUP_A2_Road_PMC_dirt2_2250",0,0,0],
	["CUP_A2_Road_PMC_dirt2_25",0,0,0],
	["CUP_A2_Road_PMC_dirt2_3025",0,0,0],
	["CUP_A2_Road_PMC_dirt2_6konec",0,0,0],
	["CUP_A2_Road_PMC_dirt2_7100",0,0,0],
    ["Land_ClutterCutter_large_F",0,0,0]
];

support_vehicles = [
    [Arsenal_typename,100,200,0],
    [Respawn_truck_typename,200,0,100],
    [FOB_box_typename,300,500,0],
    [FOB_truck_typename,300,500,75],
    [KP_liberation_small_storage_building,0,0,0],
    [KP_liberation_large_storage_building,0,0,0],
    [KP_liberation_recycle_building,250,0,0],
    [KP_liberation_air_vehicle_building,1000,0,0],
    [KP_liberation_heli_slot_building,250,0,0],
    [KP_liberation_plane_slot_building,500,0,0],
    ["ACE_medicalSupplyCrate_advanced",50,0,0],
    ["ACE_Box_82mm_Mo_HE",50,40,0],
    ["ACE_Box_82mm_Mo_Smoke",50,10,0],
    ["ACE_Box_82mm_Mo_Illum",50,10,0],
    ["ACE_Wheel",10,0,0],
    ["ACE_Track",10,0,0],
    ["USAF_missileCart_W_AGM114",50,150,0],                             // Missile Cart (AGM-114)
    ["USAF_missileCart_AGMMix",50,150,0],                               // Missile Cart (AGM-65 Mix)
    ["USAF_missileCart_AGM1",50,150,0],                                 // Missile Cart (AGM-65D)
    ["USAF_missileCart_AGM2",50,150,0],                                 // Missile Cart (AGM-65E)
    ["USAF_missileCart_AGM3",50,150,0],                                 // Missile Cart (AGM-65K)
    ["USAF_missileCart_AA1",50,150,0],                                  // Missile Cart (AIM-9M/AIM-120)
    ["USAF_missileCart_AA2",50,150,0],                                  // Missile Cart (AIM-9X/AIM-120)
    ["USAF_missileCart_GBU12_green",50,150,0],                          // Missile Cart (GBU12 Green)
    ["USAF_missileCart_GBU12_maritime",50,150,0],                       // Missile Cart (GBU12 Maritime)
    ["USAF_missileCart_GBU12",50,150,0],                                // Missile Cart (GBU12)
    ["USAF_missileCart_Gbu31",50,150,0],                                // Missile Cart (GBU31)
    ["USAF_missileCart_GBU39",50,150,0],                                // Missile Cart (GBU39)
    ["USAF_missileCart_Mk82",50,150,0],                                 // Missile Cart (Mk82)
    ["rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy",150,0,100],
    ["rhsusf_M977A4_REPAIR_usarmy_d",325,0,75],                         // M977A4 Repair
	["UK3CB_BAF_MAN_HX58_Repair_Sand",300,0,75],
	["UK3CB_BAF_MAN_HX60_Repair_Sand",325,0,100],
    ["rhsusf_M978A4_usarmy_d",125,0,275],                               // M978A4 Fuel
	["UK3CB_BAF_MAN_HX58_Fuel_Sand",125,0,275],
	["UK3CB_BAF_MAN_HX60_Fuel_Sand",150,0,300],
    ["rhsusf_M977A4_AMMO_usarmy_d",125,200,75],                         // M977A4 Ammo
    ["B_Slingload_01_Repair_F",275,0,0],                                // Huron Repair
    ["B_Slingload_01_Fuel_F",75,0,200],                                 // Huron Fuel
    ["B_Slingload_01_Ammo_F",75,200,0]                                  // Huron Ammo
];

/*
    --- Squads ---
    Pre-made squads for the commander build menu.
    These shouldn't exceed 10 members.
*/

// Light infantry squad.
blufor_squad_inf_light = [
    "rhsusf_army_ocp_teamleader",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_riflemanat",
    "rhsusf_army_ocp_grenadier",
    "rhsusf_army_ocp_autorifleman",
    "rhsusf_army_ocp_autorifleman",
    "rhsusf_army_ocp_marksman",
    "rhsusf_army_ocp_medic",
    "rhsusf_army_ocp_engineer"
];

// Heavy infantry squad.
blufor_squad_inf = [
    "rhsusf_army_ocp_teamleader",
    "rhsusf_army_ocp_riflemanat",
    "rhsusf_army_ocp_riflemanat",
    "rhsusf_army_ocp_grenadier",
    "rhsusf_army_ocp_autorifleman",
    "rhsusf_army_ocp_autorifleman",
    "rhsusf_army_ocp_machinegunner",
    "rhsusf_army_ocp_marksman",
    "rhsusf_army_ocp_medic",
    "rhsusf_army_ocp_engineer"
];

// AT specialists squad.
blufor_squad_at = [
    "rhsusf_army_ocp_teamleader",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_javelin",
    "rhsusf_army_ocp_javelin",
    "rhsusf_army_ocp_javelin",
    "rhsusf_army_ocp_medic",
    "rhsusf_army_ocp_rifleman"
];

// AA specialists squad.
blufor_squad_aa = [
    "rhsusf_army_ocp_teamleader",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_rifleman",
    "rhsusf_army_ocp_aa",
    "rhsusf_army_ocp_aa",
    "rhsusf_army_ocp_aa",
    "rhsusf_army_ocp_medic",
    "rhsusf_army_ocp_rifleman"
];

// Force recon squad.
blufor_squad_recon = [
    "rhsusf_usmc_recon_marpat_d_teamleader",
    "rhsusf_usmc_recon_marpat_d_rifleman",
    "rhsusf_usmc_recon_marpat_d_rifleman",
    "rhsusf_usmc_recon_marpat_d_rifleman_at",
    "rhsusf_usmc_recon_marpat_d_autorifleman",
    "rhsusf_usmc_recon_marpat_d_machinegunner",
    "rhsusf_usmc_recon_marpat_d_marksman",
    "rhsusf_usmc_recon_marpat_d_sniper_M107",
    "rhsusf_army_ocp_medic",
    "rhsusf_army_ocp_engineer"
];

// Paratroopers squad (The units of this squad will automatically get parachutes on build)
blufor_squad_para = [
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st",
    "rhsusf_army_ocp_rifleman_101st"
];

/*
    --- Elite vehicles ---
    Classnames below have to be unlocked by capturing military bases.
    Which base locks a vehicle is randomized on the first start of the campaign.
*/
elite_vehicles = [
	"UK3CB_BAF_MQ9_Reaper",
	"UK3CB_BAF_Apache_AH1_DynamicLoadout",
	"UK3CB_BAF_Apache_AH1_CAS",
	"UK3CB_BAF_Apache_AH1_AT",
	"B_Plane_Fighter_01_F",
	"rhsusf_m109d_usarmy",
	"RHS_AH64D",
	"RHS_M2A3_BUSKIII",
	"rhsusf_m1a1aim_tuski_d",
	"rhsusf_m1a2sep1tuskid_usarmy",
	"rhsusf_m1a2sep1tuskiid_usarmy",
	"RHS_A10",
	"USAF_AC130U",
	"B_T_VTOL_01_ARMED_F",
	"USAF_MQ9",
	"USAF_A10",
	"USAF_F22_Heavy",
	"USAF_F35A"
];
