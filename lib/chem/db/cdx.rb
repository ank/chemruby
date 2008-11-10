#
# cdx.rb - Cambridge Software cdx and cdxml file parser library
#
# Copyright (C) 2005 Nobuya Tanaka <t@chemruby.org>
#
# Example:
#   cdx_file = Chem.open_mol("hypericin.cdx")
#   puts cdx_file.to_xml
#


require 'chem/data/periodic_table'

module Chem
  module CDX
    # 
    Cdx_value2name = {
      0x0001=>['CreationUserName', :CDXString],
      0x0002=>['CreationDate', :CDXDate],
      0x0003=>['CreationProgram', :CDXString],
      0x0004=>['ModificationUserName', :CDXString],
      0x0005=>['ModificationDate', :CDXDate],
      0x0006=>['ModificationProgram', :CDXString],
      0x0008=>['Name', :CDXString],
      0x0009=>['Comment', :CDXString],
      0x000A=>['Z', :INT16],
      0x000B=>['RegistryNumber', :CDXString],
      0x000C=>['RegistryAuthority', :CDXString],
      0x000E=>['RepresentsProperty', :CDXRepresentsProperty],
      0x000F=>['IgnoreWarnings', :CDXBooleanImplied],
      0x0010=>['Warning', :CDXString],
      0x0011=>['Visible', :CDXBoolean],
      0x0100=>['fonttable', :CDXFontTable],
      0x0200=>['p', :CDXPoint2D],
      0x0201=>['xyz', :CDXPoint3D],
      0x0202=>['extent', :CDXPoint2D],
      0x0203=>['extent3D', :CDXPoint3D],
      0x0204=>['BoundingBox', :CDXRectangle],
      0x0205=>['RotationAngle', :INT32],
      0x0207=>['Head3D', :CDXPoint3D],
      0x0208=>['Tail3D', :CDXPoint3D],
      0x0209=>['TopLeft', :CDXPoint2D],
      0x020A=>['TopRight', :CDXPoint2D],
      0x020B=>['BottomRight', :CDXPoint2D],
      0x020C=>['BottomLeft', :CDXPoint2D],
      0x020D=>['Width', :CDXCoordinate],
      0x020E=>['Height', :CDXCoordinate],
      0x0300=>['colortable', :CDXColorTable],
      0x0301=>['color', :UINT16],
      0x0302=>['bgcolor', :INT16],
      0x0400=>['NodeType', :INT16],
      0x0401=>['LabelDisplay', :INT8],
      0x0402=>['Element', :INT16],
      0x0403=>['ElementList', :CDXElementList],
      0x0404=>['Formula', :CDXFormula],
      0x0420=>['Isotope', :INT16],
      0x0421=>['Charge', :INT8],
      0x0422=>['Radical', :UINT8],
      0x0423=>['FreeSites', :UINT8],
      0x0424=>['ImplicitHydrogens', :CDXBooleanImplied],
      0x0425=>['RingBondCount', :INT8],
      0x0426=>['UnsaturatedBonds', :INT8],
      0x0427=>['RxnChange', :CDXBooleanImplied],
      0x0428=>['RxnStereo', :INT8],
      0x0429=>['AbnormalValence', :CDXBooleanImplied],
      0x042B=>['NumHydrogens', :UINT16],
      0x042E=>['HDot', :CDXBooleanImplied],
      0x042F=>['HDash', :CDXBooleanImplied],
      0x0430=>['Geometry', :INT8],
      0x0431=>['BondOrdering', :CDXObjectIDArray],
      0x0432=>['Attachments', :CDXObjectIDArrayWithCounts],
      0x0433=>['GenericNickname', :CDXString],
      0x0434=>['AltGroupID', :CDXObjectID],
      0x0435=>['SubstituentsUpTo', :UINT8],
      0x0436=>['SubstituentsExactly', :UINT8],
      0x0437=>['AS', :INT8],
      0x0438=>['Translation', :INT8],
      0x0439=>['AtomNumber', :CDXString],
      0x043A=>['ShowAtomQuery', :CDXBoolean],
      0x043B=>['ShowAtomStereo', :CDXBoolean],
      0x043C=>['ShowAtomNumber', :CDXBoolean],
      0x043D=>['LinkCountLow', :INT16],
      0x043E=>['LinkCountHigh', :INT16],
      0x043F=>['IsotopicAbundance', :INT8],
      0x0500=>['Racemic', :CDXBoolean],
      0x0501=>['Absolute', :CDXBoolean],
      0x0502=>['Relative', :CDXBoolean],
      0x0503=>['Formula', :CDXFormula],
      0x0504=>['Weight', :FLOAT64],
      0x0505=>['ConnectionOrder', :CDXObjectIDArray],
      0x0600=>['Order', :INT16],
      0x0601=>['Display', :INT16],
      0x0602=>['Display2', :INT16],
      0x0603=>['DoublePosition', :INT16],
      0x0604=>['B', :CDXObjectID],
      0x0605=>['E', :CDXObjectID],
      0x0606=>['Topology', :INT8],
      0x0607=>['RxnParticipation', :INT8],
      0x0608=>['BeginAttach', :UINT8],
      0x0609=>['EndAttach', :UINT8],
      0x060A=>['BS', :INT8],
      0x060B=>['BondCircularOrdering', :CDXObjectIDArray],
      0x060C=>['ShowBondQuery', :CDXBoolean],
      0x060D=>['ShowBondStereo', :CDXBoolean],
      0x060E=>['CrossingBonds', :CDXObjectIDArray],
      0x060F=>['ShowBondRxn', :CDXBoolean],
      0x0700=>['temp_Text', :CDXString],
      0x0701=>['Justification', :INT8],
      0x0702=>['LineHeight', :UINT16],
      0x0703=>['WordWrapWidth', :INT16],
      0x0704=>['LineStarts', :INT16ListWithCounts],
      0x0705=>['LabelAlignment', :INT8],
      0x0706=>['LabelLineHeight', :INT16],
      0x0707=>['CaptionLineHeight', :INT16],
      0x0708=>['InterpretChemically', :CDXBooleanImplied],
      0x0800=>['MacPrintInfo', :Unformatted],
      0x0801=>['WinPrintInfo', :Unformatted],
      0x0802=>['PrintMargins', :CDXRectangle],
      0x0803=>['ChainAngle', :INT32],
      0x0804=>['BondSpacing', :INT16],
      0x0805=>['BondLength', :CDXCoordinate],
      0x0806=>['BoldWidth', :CDXCoordinate],
      0x0807=>['LineWidth', :CDXCoordinate],
      0x0808=>['MarginWidth', :CDXCoordinate],
      0x0809=>['HashSpacing', :CDXCoordinate],
      0x080A=>['temp_LabelStyle', :CDXFontStyle],
      0x080B=>['temp_CaptionStyle', :CDXFontStyle],
      0x080C=>['CaptionJustification', :INT8],
      0x080D=>['FractionalWidths', :CDXBooleanImplied],
      0x080E=>['Magnification', :INT16],
      0x080F=>['WidthPages', :INT16],
      0x0810=>['HeightPages', :INT16],
      0x0811=>['DrawingSpace', :INT8],
      0x0812=>['Width', :CDXCoordinate],
      0x0813=>['Height', :CDXCoordinate],
      0x0814=>['PageOverlap', :CDXCoordinate],
      0x0815=>['Header', :CDXString],
      0x0816=>['HeaderPosition', :CDXCoordinate],
      0x0817=>['Footer', :CDXString],
      0x0818=>['FooterPosition', :CDXCoordinate],
      0x0819=>['PrintTrimMarks', :CDXBooleanImplied],
      0x081A=>['LabelFont', :INT16],
      0x081B=>['CaptionFont', :INT16],
      0x081C=>['LabelSize', :INT16],
      0x081D=>['CaptionSize', :INT16],
      0x081E=>['LabelFace', :INT16],
      0x081F=>['CaptionFace', :INT16],
      0x0820=>['LabelColor', :INT16],
      0x0821=>['CaptionColor', :INT16],
      0x0822=>['BondSpacingAbs', :CDXCoordinate],
      0x0823=>['LabelJustification', :INT8],
      0x0824=>['FixInPlaceExtent', :CDXPoint2D],
      0x0825=>['Side', :UINT16],
      0x0900=>['WindowIsZoomed', :CDXBooleanImplied],
      0x0901=>['WindowPosition', :CDXPoint2D],
      0x0902=>['WindowSize', :CDXPoint2D],
      0x0A00=>['GraphicType', :INT16],
      0x0A01=>['LineType', :INT16],
      0x0A02=>['ArrowType', :INT16],
      0x0A03=>['RectangleType', :INT16],
      0x0A04=>['OvalType', :INT16],
      0x0A05=>['OrbitalType', :INT16],
      0x0A06=>['BracketType', :INT16],
      0x0A07=>['SymbolType', :INT16],
      0x0A08=>['CurveType', :INT16],
      0x0A10=>['OriginFraction', :FLOAT64],
      0x0A11=>['SolventFrontFraction', :FLOAT64],
      0x0A12=>['SideTicks', :CDXBoolean],
      0x0A20=>['HeadSize', :INT16],
      0x0A20=>['Rf', :FLOAT64],
      0x0A21=>['AngularSize', :INT16],
      0x0A21=>['Tail', :CDXCoordinate],
      0x0A22=>['LipSize', :INT16],
      0x0A22=>['ShowRf', :CDXBoolean],
      0x0A23=>['CurvePoints', :CDXCurvePoints],
      0x0A24=>['BracketUsage', :INT8],
      0x0A25=>['PolymerRepeatPattern', :INT8],
      0x0A26=>['PolymerFlipType', :INT8],
      0x0A27=>['BracketedObjectIDs', :CDXObjectIDArray],
      0x0A28=>['RepeatCount', :FLOAT64],
      0x0A29=>['ComponentOrder', :INT16],
      0x0A2A=>['SRULabel', :CDXString],
      0x0A2B=>['GraphicID', :CDXObjectID],
      0x0A2C=>['BondID', :CDXObjectID],
      0x0A2D=>['InnerAtomID', :CDXObjectID],
      0x0A2E=>['CurvePoints3D', :CDXCurvePoints3D],
      0x0A60=>['Edition', :Unformatted],
      0x0A61=>['EditionAlias', :Unformatted],
      0x0A62=>['MacPICT', :Unformatted],
      0x0A63=>['WindowsMetafile', :Unformatted],
      0x0A64=>['OLEObject', :Unformatted],
      0x0A80=>['XSpacing', :FLOAT64],
      0x0A81=>['XLow', :FLOAT64],
      0x0A82=>['XType', :INT16],
      0x0A83=>['YType', :INT16],
      0x0A84=>['XAxisLabel', :CDXString],
      0x0A85=>['YAxisLabel', :CDXString],
      0x0A86=>['temp_SpectrumDataPoint', :FLOAT64],
      0x0A87=>['Class', :INT16],
      0x0A88=>['YLow', :FLOAT64],
      0x0A89=>['YScale', :FLOAT64],
      0x0B00=>['TextFrame', :CDXRectangle],
      0x0B01=>['GroupFrame', :CDXRectangle],
      0x0B02=>['Valence', :INT16],
      0x0B80=>['GeometricFeature', :INT8],
      0x0B81=>['RelationValue', :FLOAT64],
      0x0B82=>['BasisObjects', :CDXObjectIDArray],
      0x0B83=>['ConstraintType', :INT8],
      0x0B84=>['ConstraintMin', :FLOAT64],
      0x0B85=>['ConstraintMax', :FLOAT64],
      0x0B86=>['IgnoreUnconnectedAtoms', :CDXBooleanImplied],
      0x0B87=>['DihedralIsChiral', :CDXBooleanImplied],
      0x0B88=>['PointIsDirected', :CDXBooleanImplied],
      0x0C00=>['ReactionStepAtomMap', :CDXObjectIDArray],
      0x0C01=>['ReactionStepReactants', :CDXObjectIDArray],
      0x0C02=>['ReactionStepProducts', :CDXObjectIDArray],
      0x0C03=>['ReactionStepPlusses', :CDXObjectIDArray],
      0x0C04=>['ReactionStepArrows', :CDXObjectIDArray],
      0x0C05=>['ReactionStepObjectsAboveArrow', :CDXObjectIDArray],
      0x0C06=>['ReactionStepObjectsBelowArrow', :CDXObjectIDArray],
      0x0C07=>['ReactionStepAtomMapManual', :CDXObjectIDArray],
      0x0C08=>['ReactionStepAtomMapAuto', :CDXObjectIDArray],
      0x0D00=>['TagType', :INT16],
      0x0D03=>['Tracking', :CDXBoolean],
      0x0D04=>['Persistent', :CDXBoolean],
      0x0D05=>['Value', :varies],
      0x0D06=>['PositioningType', :INT8],
      0x0D07=>['PositioningAngle', :INT32],
      0x0D08=>['PositioningOffset', :CDXPoint2D],
      0x0E00=>['SequenceIdentifier', :CDXString],
      0x0F00=>['CrossReferenceContainer', :CDXString],
      0x0F01=>['CrossReferenceDocument', :CDXString],
      0x0F02=>['CrossReferenceIdentifier', :CDXString],
      0x0F03=>['CrossReferenceSequence', :CDXString],
      0x1000=>['PaneHeight', :CDXCoordinate],
      0x1001=>['NumRows', :INT16],
      0x1002=>['NumColumns', :INT16],
      0x1100=>['Integral', :CDXBoolean],
      0x1FF0=>['SplitterPositions', :CDXObjectIDArray],
      0x1FF1=>['PageDefinition', :INT8],
      0x206=>['BoundsInParent', :CDXRectangle],
      0x8000=>['CDXML', :CDXObject],
      0x8001=>['page', :CDXObject],
      0x8002=>['group', :CDXObject],
      0x8003=>['fragment', :CDXObject],
      0x8004=>['n', :CDXObject],
      0x8005=>['b', :CDXObject],
      0x8006=>['t', :CDXObject],
      0x8007=>['graphic', :CDXObject],
      0x8017=>['bracketedgroup', :CDXObject],
      0x8018=>['bracketattachment', :CDXObject],
      0x8019=>['crossingbond', :CDXObject],
      0x8008=>['curve', :CDXObject],
      0x8009=>['embeddedobject', :CDXObject],
      0x8016=>['table', :CDXObject],
      0x800A=>['altgroup', :CDXObject],
      0x800B=>['templategrid', :CDXObject],
      0x800C=>['regnum', :CDXObject],
      0x800D=>['scheme', :CDXObject],
      0x800E=>['step', :CDXObject],
      0x8010=>['spectrum', :CDXObject],
      0x8011=>['objecttag', :CDXObject],
      0x8013=>['sequence', :CDXObject],
      0x8014=>['crossreference', :CDXObject],
      0x8020=>['border', :CDXObject],
      0x8021=>['geometry', :CDXObject],
      0x8022=>['constraint', :CDXObject],
      0x8023=>['tlcplate', :CDXObject],
      0x8024=>['tlclane', :CDXObject],
      0x8025=>['tlcspot', :CDXObject],
      0x8015=>['splitter', :CDXObject],
      0x9000=>['font', :CDXStyle],#Temporarily use user defined id by Nobuya Tanaka.
      0x9001=>['s', :CDXStyle],#Temporarily use user defined id by Nobuya Tanaka.
      #                   0x000e=>['represent', :CDXObject],
    }

    Cdx_name2value = {'CreationUserName'=>0x0001,
      'CreationDate'=>0x0002,
      'CreationProgram'=>0x0003,
      'ModificationUserName'=>0x0004,
      'ModificationDate'=>0x0005,
      'ModificationProgram'=>0x0006,
      'Name'=>0x0008,
      'Comment'=>0x0009,
      'Z'=>0x000A,
      'RegistryNumber'=>0x000B,
      'RegistryAuthority'=>0x000C,
      'RepresentsProperty'=>0x000E,
      'IgnoreWarnings'=>0x000F,
      'Warning'=>0x0010,
      'Visible'=>0x0011,
      'fonttable'=>0x0100,
      'p'=>0x0200,
      'xyz'=>0x0201,
      'extent'=>0x0202,
      'extent3D'=>0x0203,
      'BoundingBox'=>0x0204,
      'RotationAngle'=>0x0205,
      'Head3D'=>0x0207,
      'Tail3D'=>0x0208,
      'TopLeft'=>0x0209,
      'TopRight'=>0x020A,
      'BottomRight'=>0x020B,
      'BottomLeft'=>0x020C,
      'Width'=>0x020D,
      'Height'=>0x020E,
      'colortable'=>0x0300,
      'color'=>0x0301,
      'bgcolor'=>0x0302,
      'NodeType'=>0x0400,
      'LabelDisplay'=>0x0401,
      'Element'=>0x0402,
      'ElementList'=>0x0403,
      'Formula'=>0x0404,
      'Isotope'=>0x0420,
      'Charge'=>0x0421,
      'Radical'=>0x0422,
      'FreeSites'=>0x0423,
      'ImplicitHydrogens'=>0x0424,
      'RingBondCount'=>0x0425,
      'UnsaturatedBonds'=>0x0426,
      'RxnChange'=>0x0427,
      'RxnStereo'=>0x0428,
      'AbnormalValence'=>0x0429,
      'NumHydrogens'=>0x042B,
      'HDot'=>0x042E,
      'HDash'=>0x042F,
      'Geometry'=>0x0430,
      'BondOrdering'=>0x0431,
      'Attachments'=>0x0432,
      'GenericNickname'=>0x0433,
      'AltGroupID'=>0x0434,
      'SubstituentsUpTo'=>0x0435,
      'SubstituentsExactly'=>0x0436,
      'AS'=>0x0437,
      'Translation'=>0x0438,
      'AtomNumber'=>0x0439,
      'ShowAtomQuery'=>0x043A,
      'ShowAtomStereo'=>0x043B,
      'ShowAtomNumber'=>0x043C,
      'LinkCountLow'=>0x043D,
      'LinkCountHigh'=>0x043E,
      'IsotopicAbundance'=>0x043F,
      'Racemic'=>0x0500,
      'Absolute'=>0x0501,
      'Relative'=>0x0502,
      'Formula'=>0x0503,
      'Weight'=>0x0504,
      'ConnectionOrder'=>0x0505,
      'Order'=>0x0600,
      'Display'=>0x0601,
      'Display2'=>0x0602,
      'DoublePosition'=>0x0603,
      'B'=>0x0604,
      'E'=>0x0605,
      'Topology'=>0x0606,
      'RxnParticipation'=>0x0607,
      'BeginAttach'=>0x0608,
      'EndAttach'=>0x0609,
      'BS'=>0x060A,
      'BondCircularOrdering'=>0x060B,
      'ShowBondQuery'=>0x060C,
      'ShowBondStereo'=>0x060D,
      'CrossingBonds'=>0x060E,
      'ShowBondRxn'=>0x060F,
      'temp_Text'=>0x0700,
      'Justification'=>0x0701,
      'LineHeight'=>0x0702,
      'WordWrapWidth'=>0x0703,
      'LineStarts'=>0x0704,
      'LabelAlignment'=>0x0705,
      'LabelLineHeight'=>0x0706,
      'CaptionLineHeight'=>0x0707,
      'InterpretChemically'=>0x0708,
      'MacPrintInfo'=>0x0800,
      'WinPrintInfo'=>0x0801,
      'PrintMargins'=>0x0802,
      'ChainAngle'=>0x0803,
      'BondSpacing'=>0x0804,
      'BondLength'=>0x0805,
      'BoldWidth'=>0x0806,
      'LineWidth'=>0x0807,
      'MarginWidth'=>0x0808,
      'HashSpacing'=>0x0809,
      'temp_LabelStyle'=>0x080A,
      'temp_CaptionStyle'=>0x080B,
      'CaptionJustification'=>0x080C,
      'FractionalWidths'=>0x080D,
      'Magnification'=>0x080E,
      'WidthPages'=>0x080F,
      'HeightPages'=>0x0810,
      'DrawingSpace'=>0x0811,
      'Width'=>0x0812,
      'Height'=>0x0813,
      'PageOverlap'=>0x0814,
      'Header'=>0x0815,
      'HeaderPosition'=>0x0816,
      'Footer'=>0x0817,
      'FooterPosition'=>0x0818,
      'PrintTrimMarks'=>0x0819,
      'LabelFont'=>0x081A,
      'CaptionFont'=>0x081B,
      'LabelSize'=>0x081C,
      'CaptionSize'=>0x081D,
      'LabelFace'=>0x081E,
      'CaptionFace'=>0x081F,
      'LabelColor'=>0x0820,
      'CaptionColor'=>0x0821,
      'BondSpacingAbs'=>0x0822,
      'LabelJustification'=>0x0823,
      'FixInPlaceExtent'=>0x0824,
      'Side'=>0x0825,
      'WindowIsZoomed'=>0x0900,
      'WindowPosition'=>0x0901,
      'WindowSize'=>0x0902,
      'GraphicType'=>0x0A00,
      'LineType'=>0x0A01,
      'ArrowType'=>0x0A02,
      'RectangleType'=>0x0A03,
      'OvalType'=>0x0A04,
      'OrbitalType'=>0x0A05,
      'BracketType'=>0x0A06,
      'SymbolType'=>0x0A07,
      'CurveType'=>0x0A08,
      'OriginFraction'=>0x0A10,
      'SolventFrontFraction'=>0x0A11,
      'SideTicks'=>0x0A12,
      'HeadSize'=>0x0A20,
      'Rf'=>0x0A20,
      'AngularSize'=>0x0A21,
      'Tail'=>0x0A21,
      'LipSize'=>0x0A22,
      'ShowRf'=>0x0A22,
      'CurvePoints'=>0x0A23,
      'BracketUsage'=>0x0A24,
      'PolymerRepeatPattern'=>0x0A25,
      'PolymerFlipType'=>0x0A26,
      'BracketedObjectIDs'=>0x0A27,
      'RepeatCount'=>0x0A28,
      'ComponentOrder'=>0x0A29,
      'SRULabel'=>0x0A2A,
      'GraphicID'=>0x0A2B,
      'BondID'=>0x0A2C,
      'InnerAtomID'=>0x0A2D,
      'CurvePoints3D'=>0x0A2E,
      'Edition'=>0x0A60,
      'EditionAlias'=>0x0A61,
      'MacPICT'=>0x0A62,
      'WindowsMetafile'=>0x0A63,
      'OLEObject'=>0x0A64,
      'XSpacing'=>0x0A80,
      'XLow'=>0x0A81,
      'XType'=>0x0A82,
      'YType'=>0x0A83,
      'XAxisLabel'=>0x0A84,
      'YAxisLabel'=>0x0A85,
      'temp_SpectrumDataPoint'=>0x0A86,
      'Class'=>0x0A87,
      'YLow'=>0x0A88,
      'YScale'=>0x0A89,
      'TextFrame'=>0x0B00,
      'GroupFrame'=>0x0B01,
      'Valence'=>0x0B02,
      'GeometricFeature'=>0x0B80,
      'RelationValue'=>0x0B81,
      'BasisObjects'=>0x0B82,
      'ConstraintType'=>0x0B83,
      'ConstraintMin'=>0x0B84,
      'ConstraintMax'=>0x0B85,
      'IgnoreUnconnectedAtoms'=>0x0B86,
      'DihedralIsChiral'=>0x0B87,
      'PointIsDirected'=>0x0B88,
      'ReactionStepAtomMap'=>0x0C00,
      'ReactionStepReactants'=>0x0C01,
      'ReactionStepProducts'=>0x0C02,
      'ReactionStepPlusses'=>0x0C03,
      'ReactionStepArrows'=>0x0C04,
      'ReactionStepObjectsAboveArrow'=>0x0C05,
      'ReactionStepObjectsBelowArrow'=>0x0C06,
      'ReactionStepAtomMapManual'=>0x0C07,
      'ReactionStepAtomMapAuto'=>0x0C08,
      'TagType'=>0x0D00,
      'Tracking'=>0x0D03,
      'Persistent'=>0x0D04,
      'Value'=>0x0D05,
      'PositioningType'=>0x0D06,
      'PositioningAngle'=>0x0D07,
      'PositioningOffset'=>0x0D08,
      'SequenceIdentifier'=>0x0E00,
      'CrossReferenceContainer'=>0x0F00,
      'CrossReferenceDocument'=>0x0F01,
      'CrossReferenceIdentifier'=>0x0F02,
      'CrossReferenceSequence'=>0x0F03,
      'PaneHeight'=>0x1000,
      'NumRows'=>0x1001,
      'NumColumns'=>0x1002,
      'Integral'=>0x1100,
      'SplitterPositions'=>0x1FF0,
      'PageDefinition'=>0x1FF1,
      'BoundsInParent'=>0x206,
      'CDXML'=>0x8000,
      'page'=>0x8001,
      'group'=>0x8002,
      'fragment'=>0x8003,
      'n'=>0x8004,
      'b'=>0x8005,
      't'=>0x8006,
      'graphic'=>0x8007,
      'bracketedgroup'=>0x8017,
      'bracketattachment'=>0x8018,
      'crossingbond'=>0x8019,
      'curve'=>0x8008,
      'embeddedobject'=>0x8009,
      'table'=>0x8016,
      'altgroup'=>0x800A,
      'templategrid'=>0x800B,
      'regnum'=>0x800C,
      'scheme'=>0x800D,
      'step'=>0x800E,
      'spectrum'=>0x8010,
      'objecttag'=>0x8011,
      'sequence'=>0x8013,
      'crossreference'=>0x8014,
      'border'=>0x8020,
      'geometry'=>0x8021,
      'constraint'=>0x8022,
      'tlcplate'=>0x8023,
      'tlclane'=>0x8024,
      'tlcspot'=>0x8025,
      'splitter'=>0x8015,
      'fonttable'=>0x0100,
      'font'=>0x9000,#Temporarily use user defined id by Nobuya Tanaka.
      's'=>0x9001,#Temporarily use user defined id by Nbuya Tanaka.
      #                     'colortable'=>0x0300,
      #                     'color'=>0x0301,
      'represent'=>0x000e
    }

    #   module CDX
    #     def begin_object type, id
    #       return [$cdx_name2value[type]].pack('s') + [id].pack('V')
    #     end

    #     def prop type, byte
    #       return [$cdx_name2value[type], byte.length].pack('ss') + byte
    #     end
    #   end

    class CDXCoordinate
      attr_reader :coord

      def initialize coord
        @coord = coord.to_f
      end

      def to_xml
        "%.0f" % [@coord / 65536]
      end

      def to_bin
        return [@coord].pack('l')
      end

    end

    class CDXPoint2D
      attr_reader :x, :y

      def initialize x, y
        @x, @y = x.to_f, y.to_f
      end

      def to_bin ; [@y, @x].pack('V2') ; end

      def to_xml
        "%.2f %.2f" % [@x / 65536, @y / 65536]
      end

    end

    class CDXPoint3D
    end

    class CDXRectangle
      attr_reader :top, :left, :bottom, :right

      def initialize top, left, bottom, right
        @top, @left, @bottom, @right = top.to_f, left.to_f, bottom.to_f, right.to_f
      end

      def to_bin ; [@top.to_i, @left.to_i, @bottom.to_i, @right.to_i].pack('V4') ; end 

      def to_xml
        "%.2f %.2f %.2f %.2f" % [@top / 65536, @left / 65536, @bottom / 65536, @right / 65536]
      end

    end

    class CDXBoolean

      def initialize tf
        @bool = tf
      end

      def to_xml
        @bool ? "yes" : "no"
      end

      def to_bin
        if @bool
          str = [1].pack('c')
        else
          str = [0].pack('c')
        end
        str
      end
    end

    class CDXBooleanImplied

      def initialize tf
        @bool = tf
      end

      def to_xml
        @bool ? "yes" : "no"
      end

      def to_bin
        if @bool
          str = [1].pack('c')
        else
          str = [0].pack('c')
        end
        ''
      end

    end

    class CDXColorTable

      def initialize
        @colors = []
      end

      def push r, g, b
        @colors.push([r, g, b])
      end

      def to_s #fix me
        "<colortable>"
      end

      def to_bin
        str = [@colors.length].pack('v')
        @colors.each do |color|
          str += color.pack('v3')
        end
        str
      end

      def to_xml
        str = "<colortable>\n"
        @colors.each do |c|
          str += "<color r=\"%d\" g=\"%d\" b=\"%d\"/>\n" % c.collect{|cc| cc/65535.0}
        end
        str + "</colortable>\n"
      end

    end

    class CDXCurvePoints# fix me
    end

    class CDXCurvePoints3D# fix me
    end

    class CDXElementList# fix me
    end

    class CDXFontTable
      attr_accessor :platform

      def initialize
        @fonts = []
      end

      def push_font font
        @fonts.push(font)
      end

      def to_xml
        str = "<fonttable>\n"
        @fonts.each do |font|
          str += "<font id=\"#{font.font_id}\" charset=\"#{charset(font.charset)}\" name=\"#{font.name}\"/>\n"
        end
        str + "</fonttable>\n"
      end

      def to_bin
        str = [@platform].pack('v')
        str += [@fonts.length].pack('v')
        @fonts.each do |font|
          str += [font.font_id, font.charset, font.name.length, font.name].pack('vvva*')
        end
        str
      end
      CS = {
        0=>'Unknown',
        37=>'EBCDICOEM',
        437=>'MSDOSUS',
        500=>'EBCDIC500V1',
        708=>'ASMO-708',
        709=>'ArabicASMO449P',
        710=>'ArabicTransparent',
        720=>'DOS-720',
        737=>'Greek437G',
        775=>'cp775',
        850=>'windows-850',
        852=>'ibm852',
        855=>'cp855',
        857=>'cp857',
        860=>'cp860',
        861=>'cp861',
        862=>'DOS-862',
        863=>'cp863',
        864=>'cp864',
        865=>'cp865',
        866=>'cp866',
        869=>'cp869',
        874=>'windows-874',
        875=>'EBCDIC',
        932=>'shift_jis',
        936=>'gb2312',
        949=>'ks_c_5601-1987',
        950=>'big5',
        1200=>'iso-10646',
        1250=>'windows-1250',
        1251=>'windows-1251',
        1252=>'iso-8859-1',
        1253=>'iso-8859-7',
        1254=>'iso-8859-9',
        1255=>'windows-1255',
        1256=>'windows-1256',
        1257=>'windows-1257',
        1258=>'windows-1258',
        1361=>'windows-1361',
        10000=>'x-mac-roman',
        10001=>'x-mac-japanese',
        10002=>'x-mac-tradchinese',
        10003=>'x-mac-korean',
        10004=>'x-mac-arabic',
        10005=>'x-mac-hebrew',
        10006=>'x-mac-greek',
        10007=>'x-mac-cyrillic',
        10008=>'x-mac-reserved',
        10009=>'x-mac-devanagari',
        10010=>'x-mac-gurmukhi',
        10011=>'x-mac-gujarati',
        10012=>'x-mac-oriya',
        10013=>'x-mac-nengali',
        10014=>'x-mac-tamil',
        10015=>'x-mac-telugu',
        10016=>'x-mac-kannada',
        10017=>'x-mac-Malayalam',
        10018=>'x-mac-sinhalese',
        10019=>'x-mac-burmese',
        10020=>'x-mac-khmer',
        10021=>'x-mac-thai',
        10022=>'x-mac-lao',
        10023=>'x-mac-georgian',
        10024=>'x-mac-armenian',
        10025=>'x-mac-simpChinese',
        10026=>'x-mac-tibetan',
        10027=>'x-mac-mongolian',
        10028=>'x-mac-ethiopic',
        10029=>'x-mac-ce',
        10030=>'x-mac-vietnamese',
        10031=>'x-mac-extArabic',
        10032=>'x-mac-uninterpreted',
        10079=>'x-mac-icelandic',
        10081=>'x-mac-turkis'
      }

      def charset cs
        CS[cs]
      end

    end

    class CDXFormula# fix me
    end

    class CDXObjectIDArray

      def initialize array
        @array = array
      end

      def to_xml
        @array.collect{|a| "%d" % a}.join(" ")
      end

      def to_bin
        @array.pack('V')
      end

    end

    class CDXObjectIDArrayWithCounts
    end

    class CDXObjectID

      def initialize object_id
        @object_id = object_id
      end

      def to_xml
        @object_id
      end

      def to_bin
        [@object_id].pack('L')
      end

    end

    class CDXRepresentsProperty
    end

    class CDXString
      Style = {
        0x00=>'plain',
        0x01=>'bold',
        0x02=>'italic',
        0x04=>'underline',
        0x08=>'outline',
        0x10=>'shadow',
        0x20=>'subscript',
        0x40=>'superscript',
        0x60=>'formula'
      }

      def initialize
        @str = ''
        @style = []
      end

      def push_string str
        @str += str
      end

      def push_style style
        @style.push(style)
      end

      def analyze str
      end

      def to_s
        @str.gsub(/'/, '&apos;')
      end

      def to_xml
        if @style.length == 0
          return "<s>%s</s>" % @str
        else
          ret = ''
          i = 0
          @style.each do |style|
            i += 1
            n = @style[i] ? @style[i][0] -1 : -1
            ret += "<s font=\"%d\" size=\"%d\" face=\"%d\">%s</s>" % [style[1], style[3] / 20, style[2], @str[style[0]..n].gsub(/'/, '&apos;')]
          end
          return ret
        end
      end

      def to_bin
        bin = [@style.length].pack('v')
        @style.each do |style|
          bin += style.pack('v*')
        end
        bin + @str.to_a.pack('a*')
      end

      def string
        @str
      end

    end

    class CDXFontStyle # fix me

      def initialize style
        @style = style
      end

      def to_bin
        @style.pack('v4')
      end

    end

    class CDXDate # fix me
    end

    class CDXLineStarts # fix me
    end

    class INT16ListWithCounts # fix me
    end

    class Unformatted # fix me

      def initialize str
        @str = str
      end

      def to_xml
        @str
      end

      def to_bin
        @str
      end

    end

    class Int8
      attr_reader :num

      def initialize num ; @num = num ; end

      def to_xml ; @num.to_s ; end

      def to_bin ; [@num].pack('c') ; end

    end

    class Uint32

      attr_reader :num

      def initialize num ; @num = num ; end

      def to_xml ; @num.to_s ; end

      def to_bin ; [@num].pack('V') ; end

    end

    class Int32

      attr_reader :num

      def initialize num ; @num = num ; end

      def to_xml ; @num.to_s ; end

      def to_bin ; [@num].pack('v') ;end

    end

    class Uint16
      attr_reader :num

      def initialize num
        @num = num
      end

      def to_xml ;    @num.to_s        ; end
      def to_bin ;    [@num].pack('v') ;  end

    end

    class Int16
      attr_reader :num
      def initialize num
        @num = num
      end
      def to_xml
        return @num.to_s
      end
      def to_bin ; [@num].pack('v') ; end
      def to_i
        @num
      end
    end

    class Uint8
      attr_reader :num
      def initialize num
        @num = num
      end
      def to_xml
        return @num.to_s
      end
    end

    class Float64
      attr_reader :num
      def initialize num
        @num = num
      end
      def to_xml
        return @num.to_s
      end
    end

    class CDXStyle# There is no such Data Types in original CDX file
      attr_accessor :face, :font, :size, :color
    end

    class CDXObject
      attr_accessor :parent, :tag, :name, :object_id
      attr_reader :properties, :objects

      Justification = {
        -1=>"Right",
        0=>'Left',
        1=>'Center',
        2=>'Full',
        3=>'Above',
        4=>'Below',
        5=>'Auto'
      }

      Label_alignment = {
        0=>"Auto",
        1=>"Left",
        2=>"Center",
        3=>"Right",
        4=>"Above",
        5=>"Below",
        6=>"Best"
      }

      Bs = {
        0=>'U',
        1=>'N',
        2=>'D',
        3=>'Z'
      }

      As = {
        0=>'U',
        1=>'N',
        2=>'R',
        3=>'S',
        4=>'r',
        5=>'s',
        6=>'u'
      }

      def initialize name, object_id
        @name, @object_id = name, object_id
        @tag = Cdx_name2value[name]
        @properties = Hash.new
        @objects = Hash.new
      end

      def to_xml
        str = "<%s\n" % [@name]
        obj = []
        str += " id=\"%d\"\n" % [@object_id] if @object_id != 0
        
        @properties.each do |k, p|
          case k
          when 'temp_LabelStyle'
            ;
          when 'temp_CaptionStyle'
            ;
          when 'temp_Text'
            obj.push(p.to_xml)
          when 'colortable'
            obj.push(p.to_xml)
          when 'fonttable'
            obj.push(p.to_xml)
          when 'LabelAlignment'
            str += " %s=\"%s\"\n" % [k, Label_alignment[p.num]]
          when 'BS'
            str += " %s=\"%s\"\n" % [k, Bs[p.num]]
          when 'AS'
            p(p)
            str += " %s=\"%s\"\n" % [k, As[p.num]]
          when 'Justification'
            str += " %s=\"%s\"\n" % [k, Justification[p.num]]
          when 'LabelJustification'
            str += " %s=\"%s\"\n" % [k, Justification[p.num]]
          when 'ChainAngle'
            str += " %s=\"%s\"\n" % [k, p.num / 65536.0]
          when 'BondSpacing'
            str += " %s=\"%s\"\n" % [k, p.num / 10.0]
          when 'LineHeight'
            if p == 1
              str += " %s=\"%s\"\n" % [k, 'auto']
            elsif p == 0
              ;#fix me
            else
              str += " %s=\"%s\"\n" % [k, p.num]
            end
          when 'LabelLineHeight'
            if p == 1
              str += " %s=\"%s\"\n" % [k, 'auto']
            elsif p == 0
              ;#fix me
            else
              str += " %s=\"%s\"\n" % [k, p]
            end
          else
            if !p.respond_to?("to_xml")
              p p
            end
            str += " %s=\"%s\"\n" % [k, p.to_xml]
          end
        end
        str += ">"
        obj.each do |o|
          str += o
        end
        #      @objects.to_a.sort{|a, b| p a[0] ; a[0]<=>b[0]}.each do |k, o|
        @objects.to_a.each do |k, o|
          str += o.to_xml
        end
        if('s' == @name)
          str += fixme#fix me
        end
        str + "</%s>" % [@name]
      end
      def to_bin
        str = ''
        str += [@tag].pack('s') + [@object_id].pack('V')
        @properties.each do |key, prop|
          value = Cdx_name2value[key]
          if value == nil
            puts key
            exit
          end
          str += [value].pack('s')
          prop_bin = prop.to_bin
          str += [prop_bin.length].pack('v')
          str += prop_bin
        end
        @objects.each do |key, obj|
          str += obj.to_bin 
        end
        str + [0x0000].pack('s')
      end

      def prop type, byte
        return [Cdx_name2value[type], byte.length].pack('ss') + byte
      end
    end

    Xml_header = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" + 
      '<!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd">'
    Bin_header = [0x56, 0x6A, 0x43, 0x44, 0x30, 0x31, 0x30, 0x30,
      0x04, 0x03, 0x02, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00].pack("c*")
    Font_class = Struct.new("CDXFont", :font_id, :charset, :length, :name)

    class CDX
      include Molecule

      def push_mol mol
        @mols.push(mol)
      end

      def to_bin
        return Bin_header + @objects.to_bin
      end

      def to_xml
        return Xml_header + @objects.to_xml
      end

      def set_id id
        return [id].pack('V')
      end

      def make_p
        @objects = CDXObject.new('CDXML', 0)
        object_id = 1
        cdxstring = CDXString.new
        cdxstring.push_string("test.cdxml")
        @objects.properties["Name"] = cdxstring
        page = CDXObject.new('page', object_id)
        @objects.objects[object_id] = page
        object_id += 1
        atomlist = {}
        @mols.last.atoms.each do |atom|
          #      1.upto(10) do |number|
          n = CDXObject.new('n', object_id)
          atomlist[atom] = n
          n.properties['Z'] = Int16.new(object_id)
          n.properties['p'] = CDXPoint2D.new((atom.x + 30) * 10 * 65536, (atom.y + 30) * 10 * 65536)
          n.properties['AS'] = Int16.new(1)
          n.properties['Element'] = Int16.new(atom.atomic_number)
          page.objects[object_id] = n
          object_id += 1
        end
        @mols.last.bonds.each do |bond|
          b = CDXObject.new('b', object_id)
          b.properties['E'] = CDXObjectID.new(atomlist[bond.e].object_id)
          b.properties['B'] = CDXObjectID.new(atomlist[bond.b].object_id)
          b.properties['Order'] = Int16.new(bond.v)
          page.objects[object_id] = b
          object_id += 1
        end
      end

      def self.open filename
        CDX.new filename
      end

      def to_xml
        Xml_header + @objects.to_xml
      end

      def objects
        @objects
      end

      def pool
        @object_pool
      end

      def self.cdx_create_object object_type, str
        case object_type
        when :CDXCoordinate
          return CDXCoordinate.new(str.unpack('l')[0])
        when :CDXPoint2D
          xy = str.unpack("V2")
          return CDXPoint2D.new(xy[1], xy[0])
        when :CDXPoint3D#fix me
          return 'fix me'
        when :CDXRectangle
          bound = str.unpack("V4")
          return CDXRectangle.new(bound[1], bound[0], bound[3], bound[2])
        when :CDXBoolean
          return CDXBoolean.new(str[0] == 0 ? false : true)
        when :CDXBooleanImplied
          return CDXBooleanImplied.new(str[0] == 0 ? false : true)
        when :CDXColorTable # fix me
          ct = CDXColorTable.new
          kaisu = str.unpack("v")[0]
          start = 2
          1.upto(kaisu) do |n|
            rgb = str[start, 6].unpack("v3")
            ct.push(rgb[0], rgb[1], rgb[2])
            start += 6
          end
          return ct
        when :CDXCurvePoints #fix me
          return 'fix me'
        when :CDXCurvePoints3D #fix me
          return 'fix me'
        when :CDXElementList #fix me
          return 'fix me'
        when :CDXFontTable #fix me
          font_table = CDXFontTable.new
          font_table.platform = str[0..1].unpack('v')[0]
          n = str[2..3].unpack('v')[0]
          start = 4
          n.times do |n|
            font = Font_class.new
            font.font_id = str[start, 2].unpack('v')[0]
            font.charset = str[start+2, 2].unpack('v')[0]
            font.length = str[start+4, 2].unpack('v')[0]
            font.name = str[start+6, font.length].unpack('a*')[0]
            #          p font.name
            start += 6 + font.length
            font_table.push_font(font)
          end
          return font_table
        when :CDXFormula #fix me
          return 'fix me'
        when :INT8
          return Int8.new(str.unpack('c')[0])
        when :UINT32
          return Uint32.new(str.unpack("V")[0])
        when :INT32
          return Int32.new(str.unpack("V")[0])
        when :UINT16
          return Uint16.new(str.unpack("v")[0])
        when :INT16
          return Int16.new(str.unpack("s")[0])
        when :UINT8
          return Uint8.new(str.unpack('C')[0])
        when :FLOAT64
          return Float64.new(str.unpack('d')[0])# fix me
        when :CDXObjectIDArray
          return CDXObjectIDArray.new(str.unpack('V*'))
        when :CDXObjectIDArrayWithCounts #fix me
          return 'fix me'
        when :CDXObjectID
          return CDXObjectID.new(str.unpack('L')[0])
        when :CDXRepresentsProperty #fix me
          return 'fix me'
        when :CDXString
          cdxstring = CDXString.new
          n = str[0..1].unpack('v')[0]
          n.times do |nn|
            start = 2 + 10 * nn
            cdxstring.push_style(str[start, 10].unpack('v5'))
          end
          cdxstring.push_string(str[(2+10*n)..-1].unpack('a*')[0])
          return cdxstring
        when :CDXFontStyle# fix me
          return CDXFontStyle.new(str[0, 10].unpack('v4'))
        when :CDXDate# fix me
          return 'fix me'
        when :CDXLineStarts# fix me
          return 'fix me'
        when :INT16ListWithCounts# fix me
          return 'fix me'
        when :Unformatted
          return Unformatted.new(str.unpack('H*')[0].upcase)
        else
          p object_type
          return str
        end
      end

      def initialize
        @mols = Array.new
        @end_object = [0x0000].pack('s')

        @object_pool = {}
      end

      def cdxml_open(filename)
        require 'rexml/document'

        @object_id = 0
        @objects = parent = CDXObject.new('CDXML', @object_id)
        @object_id += 1

        file = File.new(filename, "r")
        doc = REXML::Document.new(file)
        doc.elements.each do |element|
          parent.objects[@object_id] = recurse_cdxml(element, parent)
        end
        #      p parent
      end

      def each
        # must return each mol
      end

      def recurse_cdxml element, parent
        obj = CDXObject.new(element.name, 0)
        case element.name
        when 'color'#fix me
        when 's'#fix me
          obj.properties['']
        when 'font'#fix me
        else
          element.attributes.each do |key, att|
            if 'id' == key
              obj.object_id = att.to_i
            else
              #            puts "%s %s" % [key, $cdx_name2value[key].inspect]
              obj.properties[key] = cdxml_create_object(Cdx_value2name[Cdx_name2value[key]][1], att)
            end
          end
        end
        element.elements.each do |el|
          if el.attributes['id']
            object_id = el.attributes['id']# fix me
          else
            object_id =  @object_id
            @object_id += 1
          end
          obj.objects[@object_id] = recurse_cdxml(el, obj)
          @object_id += 1
        end
        obj
      end

      def cdxml_create_object object_type, att
        case object_type
        when :CDXStyle
          p att
        when :CDXObject
          p att
        when :CDXCoordinate
          return CDXCoordinate.new(att.to_i)
        when :CDXPoint2D
          return CDXPoint2D.new(att.split[0].to_i * 65536, att.split[1].to_i * 65536)
        when :CDXPoint3D#fix me
          return 'fix me'
        when :CDXRectangle
          bound = att.split
          return CDXRectangle.new(bound[0].to_i * 65536, bound[0].to_i * 65536, bound[3].to_i * 65536, bound[2].to_i * 65536)
        when :CDXBoolean
          return CDXBoolean.new(att == "yes")
        when :CDXBooleanImplied
          return CDXBooleanImplied.new(att == "yes")
          #       when :CDXColorTable # fix me
          #         ct = CDXColorTable.new
          #         p ct
          #         1.upto(kaisu) do |n|
          #           rgb = str[start, 6].unpack("v3")
          #           ct.push(rgb[0], rgb[1], rgb[2])
          #           start += 6
          #         end
          #         return ct
          #       when :CDXCurvePoints #fix me
          #         return 'fix me'
          #       when :CDXCurvePoints3D #fix me
          #         return 'fix me'
          #       when :CDXElementList #fix me
          #         return 'fix me'
          #       when :CDXFontTable #fix me
          #         font_table = CDXFontTable.new
          #         font_table.platform = str[0..1].unpack('v')[0]
          #         n = str[2..3].unpack('v')[0]
          #         start = 4
          #         font_class = Struct.new("Font", :font_id, :charset, :length, :name)
          #         n.times do |n|
          #           font = font_class.new
          #           font.font_id = str[start, 2].unpack('v')[0]
          #           font.charset = str[start+2, 2].unpack('v')[0]
          #           font.length = str[start+4, 2].unpack('v')[0]
          #           font.name = str[start+6, font.length].unpack('a*')[0]
          # #          p font.name
          #           start += 6 + font.length
          #           font_table.push_font(font)
          #         end
          #         return font_table
          #       when :CDXFormula #fix me
          #         return 'fix me'
        when :INT8
          return Int8.new(att.to_i)
        when :UINT32
          return Uint32.new(att.to_i)
        when :INT32
          return Int32.new(att.to_i)
        when :UINT16
          return Uint16.new(att.to_i)
        when :INT16
          return Int16.new(att.to_i)
        when :UINT8
          return Uint8.new(att.to_i)
        when :FLOAT64
          return Float64.new(att.to_i)
        when :CDXObjectIDArray
          return CDXObjectIDArray.new(att.split.collect{|i| i.to_i})
          #       when :CDXObjectIDArrayWithCounts #fix me
          #         return 'fix me'
        when :CDXObjectID
          return CDXObjectID.new(att.to_i)
          #       when :CDXRepresentsProperty #fix me
          #         return 'fix me'
        when :CDXString# may be fix me
          cdxstring = CDXString.new
          cdxstring.push_string(att)
          return cdxstring
          #         n = str[0..1].unpack('v')[0]
          #         n.times do |nn|
          #           start = 2 + 10 * nn
          #           cdxstring.push_style(str[start, 10].unpack('v5'))
          #         end
          #         cdxstring.push_string(str[(2+10*n)..-1].unpack('a*')[0])
          #         return cdxstring
          #       when :CDXFontStyle# fix me
          #         return CDXFontStyle.new(str[0, 10].unpack('v4'))
          #       when :CDXDate# fix me
          #         return 'fix me'
          #       when :CDXLineStarts# fix me
          #         return 'fix me'
          #       when :INT16ListWithCounts# fix me
          #         return 'fix me'
        when :Unformatted
          return Unformatted.new(att)
        else
          p object_type
          return "cdxml_create_object not supported data type! please fix me!"
        end
      end

      def open(filename)
        input = File.open(filename, 'r')
        input.read(8)
        input.read(4)
        input.read(16)

        @objects = parent = CDXObject.new('CDXML', 0)
        parent.parent = parent

        sp = 0
        while !input.eof? do
          tag = input.read(2).unpack("v")[0]
          if tag == 0
            sp -= 1
            parent = parent.parent
          elsif (tag & 0x8000) == 0 # Property
            num = input.read(2).unpack("v")[0]
            bytes = input.read(num)
            puts "null number %04x " % tag if Cdx_value2name[tag] == nil
            STDOUT.flush
            parent.properties[Cdx_value2name[tag][0]] =
              CDX.cdx_create_object(Cdx_value2name[tag][1], bytes)
          elsif tag == nil
            next
          else                   # Object
            id = input.read(4).unpack('V')[0]
            object = CDXObject.new(Cdx_value2name[tag][0], id)
            object.name = Cdx_value2name[tag][0]
            @object_pool[id] = object
            parent.objects[id] = object
            object.parent = parent
            parent = object
          end
        end
        self
      end

    end
  end
end
