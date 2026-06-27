from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION_START
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor


ROOT = Path(r"C:\Users\18712\Desktop\SmartHome")
OUT = ROOT / "涓撲笟瀹炰範鎶ュ憡-SmartHome鏅鸿兘瀹跺眳鎺у埗绯荤粺.docx"
MEDIA = ROOT / "entry" / "src" / "main" / "resources" / "base" / "media"


def set_run_font(run, font="瀹嬩綋", size=None, bold=None, color=None):
    run.font.name = font
    run._element.rPr.rFonts.set(qn("w:eastAsia"), font)
    run._element.rPr.rFonts.set(qn("w:ascii"), "Times New Roman")
    run._element.rPr.rFonts.set(qn("w:hAnsi"), "Times New Roman")
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    if color is not None:
        run.font.color.rgb = RGBColor.from_string(color)


def set_para(paragraph, font="瀹嬩綋", size=12, line=1.5, first_line=True, align=None, before=0, after=6):
    fmt = paragraph.paragraph_format
    fmt.space_before = Pt(before)
    fmt.space_after = Pt(after)
    fmt.line_spacing = line
    if first_line:
        fmt.first_line_indent = Cm(0.74)
    if align is not None:
        paragraph.alignment = align
    for run in paragraph.runs:
        set_run_font(run, font, size)


def add_text(doc, text, first_line=True, after=6):
    p = doc.add_paragraph()
    p.add_run(text)
    set_para(p, first_line=first_line, after=after)
    return p


def add_heading_cn(doc, text, level=1):
    p = doc.add_paragraph()
    r = p.add_run(text)
    if level == 1:
        set_run_font(r, "榛戜綋", 15, True)
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(8)
    elif level == 2:
        set_run_font(r, "榛戜綋", 13, True)
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(6)
    else:
        set_run_font(r, "瀹嬩綋", 12, True)
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.line_spacing = 1.5
    return p


def shade_cell(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), fill)
    tc_pr.append(shd)


def set_cell_text(cell, text, bold=False, align=WD_ALIGN_PARAGRAPH.CENTER):
    cell.text = ""
    p = cell.paragraphs[0]
    p.alignment = align
    r = p.add_run(text)
    set_run_font(r, "瀹嬩綋", 11, bold)
    p.paragraph_format.space_after = Pt(0)
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER


def add_table(doc, headers, rows, widths=None):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = "Table Grid"
    for i, header in enumerate(headers):
        set_cell_text(table.rows[0].cells[i], header, True)
        shade_cell(table.rows[0].cells[i], "E8EEF5")
    for row in rows:
        cells = table.add_row().cells
        for i, val in enumerate(row):
            set_cell_text(cells[i], val, False, WD_ALIGN_PARAGRAPH.LEFT if i > 0 else WD_ALIGN_PARAGRAPH.CENTER)
    if widths:
        for row in table.rows:
            for idx, width in enumerate(widths):
                row.cells[idx].width = Cm(width)
    doc.add_paragraph()
    return table


def add_caption(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(text)
    set_run_font(r, "瀹嬩綋", 10.5)
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(6)


def add_picture(doc, path, caption, width=5.6):
    if not Path(path).exists():
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run()
    run.add_picture(str(path), width=Inches(width))
    add_caption(doc, caption)


def add_code(doc, code):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Cm(0.3)
    p.paragraph_format.right_indent = Cm(0.2)
    p.paragraph_format.space_before = Pt(3)
    p.paragraph_format.space_after = Pt(5)
    p.paragraph_format.line_spacing = 1.05
    for line in code.strip().splitlines():
        r = p.add_run(line.rstrip() + "\n")
        set_run_font(r, "Consolas", 8.5)


def build():
    doc = Document()
    sec = doc.sections[0]
    sec.top_margin = Cm(2.54)
    sec.bottom_margin = Cm(2.54)
    sec.left_margin = Cm(2.8)
    sec.right_margin = Cm(2.4)

    styles = doc.styles
    styles["Normal"].font.name = "瀹嬩綋"
    styles["Normal"]._element.rPr.rFonts.set(qn("w:eastAsia"), "瀹嬩綋")
    styles["Normal"].font.size = Pt(12)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(30)
    r = p.add_run("涓撲笟瀹炰範鎶ュ憡")
    set_run_font(r, "榛戜綋", 24, True)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("锛圫martHome 鏅鸿兘瀹跺眳鎺у埗绯荤粺锛?)
    set_run_font(r, "榛戜綋", 16, True)

    cover = doc.add_table(rows=5, cols=2)
    cover.alignment = WD_TABLE_ALIGNMENT.CENTER
    cover.style = "Table Grid"
    cover_data = [
        ("涓撲笟鐝骇锛?, "璁C-23x"),
        ("瀛?   鍙凤細", ""),
        ("濮?   鍚嶏細", ""),
        ("鎸囧鑰佸笀锛?, "鐔婇潤銆佺敯寤跺畨銆佸鏂屻€佽阿浣炽€佽淳灏忎簯銆佽档鏅撱€佹潕濠夈€佺帇姊呭槈"),
        ("瀹炰範鍦扮偣锛?, "杞€氬姩鍔?),
    ]
    for idx, (label, value) in enumerate(cover_data):
        set_cell_text(cover.rows[idx].cells[0], label, True, WD_ALIGN_PARAGRAPH.RIGHT)
        set_cell_text(cover.rows[idx].cells[1], value, False, WD_ALIGN_PARAGRAPH.LEFT)
        cover.rows[idx].cells[0].width = Cm(4)
        cover.rows[idx].cells[1].width = Cm(10)

    for _ in range(4):
        doc.add_paragraph()
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("瀹炰範鏃堕棿锛?026骞?6 鏈?1 鏃ヨ嚦 2026骞?7 鏈?3 鏃?)
    set_run_font(r, "瀹嬩綋", 12, True)

    doc.add_page_break()

    add_heading_cn(doc, "涓€銆佷笓涓氬疄涔犵洰鐨勫強鎰忎箟")
    add_text(doc, "杩欐涓撲笟瀹炰範瀵规垜鏉ヨ涓嶆槸鍗曠函鎶婅鍫傛渚嬮噸鏂版暡涓€閬嶏紝鑰屾槸鎶婂墠闈㈠垎鏁ｅ鍒扮殑楦胯挋椤甸潰銆佽祫婧愮鐞嗐€丟it銆丩inux 鍜?OpenHarmony 鍩虹鐭ヨ瘑鏀惧埌涓€涓繛缁」鐩噷楠岃瘉銆傛垜鐨勭粨璇句綔涓氶€夋嫨浜?SmartHome 鏅鸿兘瀹跺眳鎺у埗绯荤粺锛屽師鍥犳槸杩欎釜棰樼洰鏃㈡湁鍙鍖栫晫闈紝鍙堟湁璁惧鐘舵€併€佸満鏅仈鍔ㄥ拰鏅鸿兘鍔╂墜閫昏緫锛岃兘澶熸毚闇插嚭鈥滈〉闈㈠ソ鐪嬧€濆拰鈥滅郴缁熻兘缁存姢鈥濅箣闂寸殑宸埆銆?)
    add_text(doc, "鍦ㄩ」鐩帹杩涜繃绋嬩腑锛屾垜閫愭笎鎰忚瘑鍒版櫤鑳藉灞呭簲鐢ㄧ殑闅剧偣骞朵笉鍙槸鎽嗗嚑涓澶囨寜閽紝鑰屾槸鎬庢牱璁╃敤鎴蜂竴鐪肩湅鎳傚閲屽彂鐢熶簡浠€涔堛€備緥濡傚鍘呯伅鍏夋墦寮€鍚庯紝鎴块棿鑳屾櫙鍥捐璺熺潃鍙樺寲锛涜繘鍏ュ崸瀹ゅ悗锛岀偣浣嶅拰璁惧璇︽儏涓嶈兘缁х画鏄剧ず瀹㈠巺鐨勬暟鎹紱鏅鸿兘鍔╂墜瑙ｆ瀽鑷劧璇█鍚庯紝涔熻鎶婃枃瀛楀彉鎴愭槑纭殑瑙﹀彂鏉′欢鍜岃澶囧姩浣溿€傝繖浜涢棶棰樹績浣挎垜浠庣姸鎬佸缓妯°€佺粍浠舵媶鍒嗐€佽祫婧愬懡鍚嶅拰浜や簰鍙嶉鍑犱釜瑙掑害閲嶆柊缁勭粐浠ｇ爜銆?)
    add_text(doc, "鍥犳锛屾湰娆″疄涔犵殑涓昏鎰忎箟鍦ㄤ簬璁╂垜鎶娾€滆兘瀹炵幇涓€涓晥鏋溾€濈殑鎬濊矾鎺ㄨ繘鍒扳€滆兘瑙ｉ噴涓€涓郴缁熶负浠€涔堣繖鏍疯璁♀€濄€傛垜涓嶅啀鍙叧娉ㄦ煇涓寜閽槸鍚﹁兘鐐癸紝鑰屾槸寮€濮嬭€冭檻鏁版嵁缁撴瀯鏄惁鏂逛究鎵╁睍銆侀〉闈㈢粍浠舵槸鍚﹀鐢ㄣ€佸紓甯告儏鍐垫槸鍚︽湁鎻愮ず銆佺涓夋柟璧勬簮鏄惁淇濈暀璁稿彲璇存槑銆傝繖涓繃绋嬭鎴戞洿鎺ヨ繎浼佷笟椤圭洰涓殑宸ョ▼鎬濈淮銆?)

    add_heading_cn(doc, "浜屻€佸疄涔犲崟浣嶇畝浠?)
    add_text(doc, "鏈瀹炰範鐢卞鏍′笌杞€氬姩鍔涚浉鍏冲疄璁祫婧愬叡鍚岀粍缁囧畬鎴愩€傚鎴戜釜浜鸿€岃█锛岃蒋閫氬姩鍔涜繖涓疄涔犵幆澧冩渶鏈変环鍊肩殑鍦版柟锛屼笉鍙槸浠嬬粛涓€瀹朵紒涓氱殑瑙勬ā鍜屼笟鍔★紝鑰屾槸鎶婁紒涓氱爺鍙戜腑甯歌鐨勫伐浣滄柟寮忓甫杩涗簡璇剧▼锛氬厛鏄庣‘闇€姹傦紝鍐嶆媶妯″潡锛涘厛鎼嚭鍙繍琛岀増鏈紝鍐嶉€愭琛ラ綈浜や簰鍜屽紓甯革紱閬囧埌闄岀敓宸ュ叿鏃讹紝鍏堟寜鏂囨。瀹屾垚鏈€灏忓彲鐢ㄦ祦绋嬶紝鍐嶇户缁繁鍏ャ€?)
    add_text(doc, "瀹炰範鍐呭涓庨缚钂欑敓鎬佸拰 OpenHarmony 鍦烘櫙缁撳悎姣旇緝绱у瘑銆傝绋嬩腑娑夊強绉诲姩绔〉闈㈠紑鍙戙€佽澶囦晶寮€鍙戠幆澧冦€丟it 鐗堟湰绠＄悊銆丩inux 鍛戒护銆丮akefile 鏋勫缓鎬濇兂绛夊唴瀹癸紝杩欎簺鐭ヨ瘑鍦?SmartHome 椤圭洰涓苟涓嶆槸瀛ょ珛鍑虹幇鐨勩€備緥濡傝祫婧愬浘鐗囧拰妯″瀷鏂囦欢闇€瑕佹寜椤圭洰鐩綍缁勭粐锛岄〉闈㈤€昏緫闇€瑕佺敤缁勪欢鍜岀姸鎬佺鐞嗘壙鎺ワ紝鏅鸿兘瀹跺眳璁惧鐨勬娊璞″張闇€瑕佸弬鑰冪墿鑱旂綉鍦烘櫙涓殑鈥滆澶囥€佺姸鎬併€佸姩浣溿€佽Е鍙戞潯浠垛€濇ā鍨嬨€?)
    add_text(doc, "鐩告瘮鍙惉浼佷笟浠嬬粛锛屾垜鏇村ぇ鐨勬敹鑾锋槸寮€濮嬬悊瑙ｈ蒋浠舵湇鍔′紒涓氫负浠€涔堝己璋冭鑼冦€佷氦浠樺拰鍗忎綔銆備竴涓簲鐢ㄥ湪涓汉鐢佃剳涓婅兘杩愯鍙槸绗竴姝ワ紝鐪熸杩涘叆浼佷笟椤圭洰鍚庯紝杩樿闈㈠澶氫汉缁存姢銆侀渶姹傚彉鍖栥€佹祴璇曢獙璇併€佺増鏉冨悎瑙勫拰鐢ㄦ埛浣撻獙绛夐棶棰樸€傝繖浜涘唴瀹圭洿鎺ュ奖鍝嶆垜鍚庨潰鍐欎唬鐮佸拰鏁寸悊鎶ュ憡鏃剁殑鍙栬垗銆?)

    add_heading_cn(doc, "涓夈€佸疄涔犳€讳綋瀹夋帓")
    add_table(
        doc,
        ["椤圭洰", "鍏蜂綋鍐呭"],
        [
            ["瀹炰範鏃堕棿", "2026骞?鏈?鏃ヨ嚦2026骞?鏈?鏃ワ紝鍏?鍛ㄣ€?],
            ["瀹炰範鍦扮偣", "杞€氬姩鍔涘疄璁幆澧冨強涓汉寮€鍙戠幆澧冦€?],
            ["瀹炰範鏂瑰悜", "楦胯挋搴旂敤寮€鍙戜笌 OpenHarmony 鏅鸿兘缁堢/鏅鸿兘瀹跺眳鏂瑰悜銆?],
            ["涓昏鍐呭", "楦胯挋鍩虹銆丄rkTS 澹版槑寮忓紑鍙戙€佺粍浠朵笌鐘舵€佺鐞嗐€丟it銆丩inux銆丮akefile銆丷K2206/OpenHarmony 璁惧渚у熀纭€銆佹櫤鑳藉灞呯患鍚堥」鐩疄璺点€?],
            ["鏈€缁堟垚鏋?, "瀹屾垚 SmartHome 鏅鸿兘瀹跺眳鎺у埗绯荤粺锛屽寘鎷椤电┖闂存€昏銆佹埧闂寸偣浣嶆帶鍒躲€佽澶囪鎯呴〉銆佹櫤鑳藉姪鎵嬩笌鑷姩鍖栬剼鏈鐞嗙瓑鍔熻兘銆?],
        ],
        [3.0, 12.0],
    )
    add_text(doc, "鏁翠綋瀹夋帓涓婏紝鍓嶆湡浠ュ熀纭€鐭ヨ瘑瀛︿範鍜屾渚嬬粌涔犱负涓伙紝鎺屾彙楦胯挋搴旂敤椤圭洰缁撴瀯銆丄rkTS 璇硶銆佺粍浠跺竷灞€銆佽祫婧愮鐞嗗拰寮€鍙戝伐鍏蜂娇鐢紱涓湡瀛︿範 Git銆丩inux銆丮akefile 涓?OpenHarmony/RK2206 璁惧渚х浉鍏崇煡璇嗭紝鐞嗚В杞欢鐮斿彂涓庤澶囧紑鍙戜箣闂寸殑鍏崇郴锛涘悗鏈熷洿缁曟櫤鑳藉灞呯粨璇句綔涓氳繘琛岄渶姹傛暣鐞嗐€佺晫闈㈣璁°€佸姛鑳藉紑鍙戙€佽皟璇曟祴璇曞拰鎶ュ憡鎬荤粨銆?)

    add_heading_cn(doc, "鍥涖€佸疄涔犲唴瀹瑰強杩囩▼")
    add_heading_cn(doc, "4.1 浼佷笟椤圭洰瀹炶返锛歋martHome 鏅鸿兘瀹跺眳鎺у埗绯荤粺", 2)
    add_text(doc, "SmartHome 鏄竴涓潰鍚戝搴綇鎴风殑楦胯挋鏅鸿兘瀹跺眳鎺у埗搴旂敤銆傜郴缁熶互鈥滃厛鐪嬪埌瀹讹紝鍐嶈繘琛屾帶鍒垛€濅负璁捐鍘熷垯锛屾墦寮€搴旂敤鍚庡憟鐜扮┖闂村寲鐨勫搴腑鎺ц鍥撅紝鐢ㄦ埛鍙互杩涘叆瀹㈠巺銆佸崸瀹ょ瓑鎴块棿锛屽湪淇鍥句腑鏌ョ湅璁惧浣嶇疆銆佺姸鎬佸拰鍙墽琛屾搷浣滐紝骞堕€氳繃璁惧璇︽儏椤靛畬鎴愬紑鍏炽€佷寒搴︺€佹俯搴︺€佺獥甯樻瘮渚嬨€佹墭绠℃ā寮忕瓑浜や簰銆傚悓鏃讹紝绯荤粺鎻愪緵鏅鸿兘鍔╂墜椤甸潰锛屽皢鑷劧璇█鎸囦护瑙ｆ瀽涓鸿澶囧姩浣滄垨鑷姩鍖栬剼鏈崏绋裤€?)
    add_picture(doc, MEDIA / "home_core_scene.png", "鍥?-1 SmartHome 棣栭〉鏍稿績鍦烘櫙璧勬簮", 5.2)

    add_heading_cn(doc, "4.1.1 鍙鎬х爺绌?, 3)
    add_text(doc, "缁忔祹鍙鎬ф柟闈紝SmartHome 浠ヨ绋嬪疄璁拰涓汉缁撹浣滀笟涓虹洰鏍囷紝涓昏浣跨敤 DevEco Studio銆丠armonyOS SDK銆丄rkTS銆侀」鐩唴鍥剧墖璧勬簮浠ュ強寮€婧?3D 瀹跺叿妯″瀷璧勬簮瀹屾垚寮€鍙戯紝涓嶉渶瑕侀澶栬喘涔扮‖浠惰澶囧拰鍟嗕笟鏈嶅姟銆傞」鐩腑鐨勮澶囩姸鎬侀噰鐢ㄦ湰鍦扮姸鎬佹ā鎷燂紝鏅鸿兘鍔╂墜浼樺厛閫氳繃鏈湴瑙勫垯瑙ｆ瀽锛屽彧鏈夋櫘閫氶棶绛斿満鏅墠棰勭暀 DeepSeek API 璋冪敤锛屽洜姝ゅ紑鍙戞垚鏈拰杩愯鎴愭湰杈冧綆銆?)
    add_text(doc, "鎶€鏈彲琛屾€ф柟闈紝楦胯挋 ArkTS 澹版槑寮?UI 閫傚悎鏋勫缓鍗＄墖銆佸垪琛ㄣ€佹粦鍧椼€佸脊灞傚拰搴曢儴瀵艰埅绛夌Щ鍔ㄧ浜や簰銆傞」鐩凡鍏峰瀹屾暣宸ョ▼缁撴瀯锛屽寘鎷?AppScope銆乪ntry 妯″潡銆佽祫婧愭枃浠躲€侀〉闈㈢粍浠跺拰鏅鸿兘鍔╂墜鏈嶅姟浠ｇ爜銆傞€氳繃 @State銆丂Prop銆丂Link 绛夌姸鎬佹満鍒讹紝鍙互瀹炵幇鎴块棿鍒囨崲銆佽澶囬€夋嫨銆佽鎯呴〉鑱斿姩鍜岃嚜鍔ㄥ寲鑴氭湰鍒楄〃鏇存柊銆傝祫婧愮洰褰曚腑鍖呭惈瀹㈠巺銆佸崸瀹ゆ棩澶滅伅鍏夌姸鎬佸浘銆佽澶囬瑙堝浘浠ュ強 glb/gltf 妯″瀷璧勬簮锛岃兘澶熸敮鎾戝浘鏂囧苟鑼傜殑绌洪棿鍖栫晫闈€?)
    add_text(doc, "绀句細鍙鎬ф柟闈紝鏅鸿兘瀹跺眳鏄眳姘戠敓娲绘暟瀛楀寲鐨勯噸瑕佹柟鍚戙€備竴涓竻鏅般€佸彲璁块棶銆佸彲鐞嗚В鐨勬帶鍒剁晫闈㈣兘澶熼檷浣庢櫘閫氱敤鎴风鐞嗗璁惧鐨勯毦搴︼紝鎻愰珮鑺傝兘銆佸畨鍏ㄥ拰鐢熸椿渚垮埄鎬с€傞」鐩櫧鐒舵槸璇剧▼绾у師鍨嬶紝浣嗗洿缁曠収鏄庛€佺┖璋冦€佺獥甯樸€佺數瑙嗐€佺┖姘斿噣鍖栧櫒銆佹壂鍦版満鍣ㄤ汉鍜屽畨闃查棬閿佺瓑甯歌瀹跺涵璁惧杩涜寤烘ā锛屽叿鏈夎緝濂界殑搴旂敤鍦烘櫙浠ｈ〃鎬с€?)

    add_heading_cn(doc, "4.1.2 闇€姹傚垎鏋?, 3)
    add_text(doc, "绯荤粺鏈嶅姟瀵硅薄涓昏鏄娇鐢?HarmonyOS 鎵嬫満銆佸钩鏉挎垨浜屽悎涓€璁惧鐨勫搴綇鎴枫€傜敤鎴峰笇鏈涘湪涓€涓叆鍙ｄ腑蹇€熶簡瑙ｅ搴綋鍓嶇姸鎬侊紝骞剁洿鎺ュ畬鎴愬父鐢ㄨ澶囨帶鍒讹紝涓嶅笇鏈涘湪澶嶆潅鑿滃崟涓€愬眰鏌ユ壘璁惧銆傚洜姝わ紝绯荤粺闇€姹傚彲鍒嗕负鍦烘櫙鎰熺煡銆佹埧闂寸鐞嗐€佽澶囨帶鍒躲€佽澶囪鎯呫€佹櫤鑳藉姪鎵嬪拰鑷姩鍖栬剼鏈叚绫汇€?)
    add_table(
        doc,
        ["鐢ㄦ埛闇€姹?, "鍔熻兘鍒嗚В", "瀹炵幇瑕佺偣"],
        [
            ["鏌ョ湅瀹跺涵鐘舵€?, "棣栭〉灞曠ず瀹㈠巺銆佸崸瀹ょ瓑绌洪棿鍏ュ彛鍜岃澶囨憳瑕併€?, "浣跨敤鎴块棿鏁版嵁妯″瀷鍜岃祫婧愬浘鐗囷紝鏍规嵁鏃ュ鐘舵€佷笌鐏厜鐘舵€佸垏鎹㈠満鏅浘銆?],
            ["鎺у埗鎴块棿璁惧", "鍦ㄦ埧闂翠刊瑙嗗浘涓偣鍑荤偣浣嶏紝鎵ц寮€鍏炽€佽皟娓┿€佽皟鍏夈€佺獥甯樻瘮渚嬬瓑鎿嶄綔銆?, "閫氳繃 PointSpec 鎻忚堪鐐逛綅鍧愭爣銆佽澶囩被鍨嬨€佽鎯呭拰鍔ㄤ綔绫诲瀷銆?],
            ["鏌ョ湅璁惧璇︽儏", "杩涘叆璁惧璇︽儏椤垫煡鐪嬫寚鏍囥€佽澶囪兘鍔涖€佽仈鍔ㄨ澶囧拰鎺у埗婊戝潡銆?, "DeviceDetailPages 缁勪欢鏍规嵁 pointId 鍖归厤璁惧椤甸潰閰嶇疆銆?],
            ["绠＄悊鑷姩鍖?, "鍒涘缓绂诲鏂數銆佸闂村叆鐫°€佸洖瀹舵ā寮忋€佸懆鏈竻娲佺瓑鑷姩鍖栬剼鏈€?, "AutomationSpec 淇濆瓨瑙﹀彂鏉′欢銆佸姩浣滃垪琛ㄣ€佹潵婧愬拰鍚敤鐘舵€併€?],
            ["鏅鸿兘鍔╂墜浜や簰", "杈撳叆鑷劧璇█鎸囦护锛岃В鏋愪负璁惧鍔ㄤ綔鎴栬剼鏈崏绋裤€?, "SmartPromptParser 璐熻矗鍏抽敭璇嶈瘑鍒€佽Е鍙戞潯浠惰В鏋愬拰鍔ㄤ綔鐢熸垚銆?],
            ["閫傞厤瑙嗚鐘舵€?, "鏀寔鏃ラ棿/澶滈棿瑙嗚銆佹寜鍘嬪弽棣堛€佸脊灞傝繃娓″拰娓呮櫚鐘舵€佹彁绀恒€?, "閫氳繃棰滆壊鍑芥暟銆佸姩鏁堝嚱鏁板拰鐘舵€佸彉閲忕粺涓€绠＄悊瑙嗚鍙嶉銆?],
        ],
        [2.6, 6.0, 6.4],
    )
    add_text(doc, "鐢ㄤ緥灞傞潰锛岀敤鎴疯繘鍏ュ簲鐢ㄥ悗棣栧厛娴忚棣栭〉涓帶瑙嗗浘锛涢€夋嫨鎴块棿鍚庤繘鍏ユ埧闂存帶鍒剁晫闈紱鐐瑰嚮璁惧鐐逛綅鍙互鎵撳紑璇︽儏闈㈡澘锛涘湪璇︽儏闈㈡澘涓彲璋冩暣璁惧鍙傛暟鎴栧惎鐢ㄦ櫤鑳芥墭绠★紱杩涘叆鏅鸿兘椤甸潰鍚庯紝鐢ㄦ埛鍙互杈撳叆鈥滄瘡澶?2:30鍏抽棴瀹㈠巺鐏€佹媺涓婂崸瀹ょ獥甯樺苟鎶婂崸瀹ょ┖璋冭皟鍒?3搴︹€濈瓑鎸囦护锛岀郴缁熺敓鎴愯嚜鍔ㄥ寲鑽夌锛岀敤鎴风‘璁ゅ悗淇濆瓨涓鸿剼鏈€?)

    add_heading_cn(doc, "4.1.3 姒傝璁捐", 3)
    add_text(doc, "绯荤粺閲囩敤鍗?entry 妯″潡缁勭粐锛屾牳蹇冮〉闈负 Index.ets锛岃澶囪鎯呮娊璞′负 DeviceDetailPages.ets锛屾櫤鑳藉姪鎵嬬浉鍏抽€昏緫鏀惧湪 smart 鐩綍涓嬨€傛暣浣撶粨鏋勪綋鐜颁簡鈥滈〉闈㈠睍绀哄眰銆佷笟鍔＄姸鎬佸眰銆佹櫤鑳借В鏋愬眰銆佽祫婧愬眰鈥濈殑鍒嗗眰鎬濊矾銆傞〉闈㈠睍绀哄眰璐熻矗 UI 鍜屼氦浜掞紝涓氬姟鐘舵€佸眰璐熻矗鎴块棿銆佽澶囧拰鑷姩鍖栫姸鎬侊紝鏅鸿兘瑙ｆ瀽灞傝礋璐ｈ嚜鐒惰瑷€鍒扮粨鏋勫寲鍔ㄤ綔鐨勮浆鎹紝璧勬簮灞傛彁渚涘浘鐗囥€佹ā鍨嬪拰閰嶇疆鏂囦欢銆?)
    add_table(
        doc,
        ["妯″潡", "涓昏鏂囦欢", "鑱岃矗"],
        [
            ["鍏ュ彛涓庝富椤甸潰", "entry/src/main/ets/pages/Index.ets", "瀹氫箟鎴块棿銆佺偣浣嶃€佸満鏅€佸鑸€佸脊灞傘€佹櫤鑳介〉涓庡叏灞€鐘舵€併€?],
            ["璁惧璇︽儏", "entry/src/main/ets/components/DeviceDetailPages.ets", "鏍规嵁璁惧 id 灞曠ず璁惧灏侀潰銆佹寚鏍囥€佹粦鍧楁帶鍒躲€佸姩浣滃垪琛ㄥ拰鑱斿姩璁惧銆?],
            ["鏅鸿兘妯″瀷", "entry/src/main/ets/smart/SmartModels.ets", "瀹氫箟娑堟伅銆佽Е鍙戝櫒銆佸姩浣溿€佽嚜鍔ㄥ寲鑴氭湰绛夋帴鍙ｃ€?],
            ["鎸囦护瑙ｆ瀽", "entry/src/main/ets/smart/SmartPromptParser.ets", "璇嗗埆鏃堕棿銆佺瀹躲€佸洖瀹躲€佹竻娲併€佺伅鍏夈€佺┖璋冦€佺獥甯樼瓑鍏抽敭璇嶅苟鐢熸垚鍔ㄤ綔銆?],
            ["鍔╂墜鏈嶅姟", "entry/src/main/ets/smart/SmartAssistantService.ets", "鍒ゆ柇鏈湴鏅鸿兘瀹跺眳鎸囦护鎴栬浆鍙戝埌 DeepSeek 鏈嶅姟銆?],
            ["璧勬簮鏂囦欢", "resources/base/media 涓?rawfile/models", "淇濆瓨鎴块棿鍥俱€佽澶囧浘銆佹ā鍨嬭祫婧愬拰璁稿彲璇存槑銆?],
        ],
        [2.6, 5.2, 7.2],
    )
    add_text(doc, "绯荤粺鍔熻兘缁撴瀯鍙鎷负锛歋martHome 搴旂敤鍖呭惈棣栭〉銆佹埧闂存帶鍒躲€佽澶囪鎯呫€佹櫤鑳藉姪鎵嬨€佽嚜鍔ㄥ寲鑴氭湰鍜岃祫婧愭ā鍨嬪叚涓儴鍒嗐€傚叾涓椤佃礋璐ｇ┖闂村叆鍙ｅ拰鏁翠綋鐘舵€侊紝鎴块棿鎺у埗璐熻矗鐐逛綅浜や簰锛岃澶囪鎯呰礋璐ｅ崟璁惧绮剧粏鎺у埗锛屾櫤鑳藉姪鎵嬭礋璐ｈ嚜鐒惰瑷€澶勭悊锛岃嚜鍔ㄥ寲鑴氭湰璐熻矗瑙﹀彂鏉′欢涓庡姩浣滃垪琛ㄧ殑鎸佷箙鍖栬〃杈俱€?)
    add_picture(doc, MEDIA / "room_living_scene.png", "鍥?-2 瀹㈠巺绌洪棿鍦烘櫙璧勬簮", 5.5)
    add_picture(doc, MEDIA / "room_bedroom_scene.png", "鍥?-3 鍗у绌洪棿鍦烘櫙璧勬簮", 5.5)

    add_heading_cn(doc, "4.1.4 璇︾粏璁捐", 3)
    add_text(doc, "鍦ㄦ暟鎹ā鍨嬭璁′笂锛孖ndex.ets 涓畾涔変簡 RoomSpec銆丳ointSpec銆丼ceneSpec銆丷oomDeviceState 绛夋帴鍙ｃ€俁oomSpec 琛ㄧず鎴块棿鍩烘湰淇℃伅鍜屽満鏅浘鐗囬泦鍚堬紝PointSpec 琛ㄧず璁惧鐐逛綅锛屽寘鎷墍灞炴埧闂淬€佹樉绀哄悕绉般€佺被鍨嬨€亁/y 鐧惧垎姣斿潗鏍囥€佽鎯呮枃鏈拰鍔ㄤ綔绫诲瀷銆傞€氳繃鐐逛綅鍧愭爣锛岃澶囧彲浠ヨ鏀剧疆鍦ㄦ埧闂村浘鐗囦腑鐨勫叿浣撲綅缃紝浣挎帶鍒跺叆鍙ｅ叿澶囩┖闂磋涔夈€?)
    add_text(doc, "鍦ㄧ姸鎬佽璁′笂锛屼富椤甸潰浣跨敤澶氫釜 @State 鍙橀噺缁存姢鐣岄潰鐘舵€侊紝渚嬪 activeTab 琛ㄧず褰撳墠搴曢儴瀵艰埅椤碉紝activeRoomId 琛ㄧず褰撳墠鎴块棿锛宻electedPointId 鍜?detailPointId 琛ㄧず褰撳墠閫変腑璁惧涓庤鎯呴潰鏉匡紝isNight 琛ㄧず鏃ュ妯″紡锛宭ivingLightOn銆乥edroomLightOn銆乴ivingTemperature銆乥edroomTemperature 绛夊彉閲忚〃绀鸿澶囩姸鎬併€傞€氳繃杩欎簺鐘舵€佸彉閲忥紝鐣岄潰鑳藉鍦ㄧ敤鎴风偣鍑汇€佹粦鍔ㄣ€佽緭鍏ュ悗鑷姩鍒锋柊銆?)
    add_text(doc, "鍦ㄩ〉闈氦浜掕璁′笂锛岄椤典娇鐢ㄥ簳閮ㄥ鑸垏鎹⑩€滃銆佹櫤鑳姐€佸晢鍩庛€佹垜鐨勨€濈瓑椤甸潰锛涙埧闂撮〉闈㈤€氳繃鍗＄墖銆佺偣浣嶅拰寮瑰眰缁勭粐淇℃伅锛涜澶囪鎯呴〉浣跨敤 Header銆丠ero銆丆ontrolDeck銆丮etrics銆丄ctionList 绛?Builder 鎷嗗垎椤甸潰缁撴瀯銆傝繖鏍锋棦闄嶄綆浜嗗崟涓?UI 鐗囨鐨勫鏉傚害锛屼篃渚夸簬鍚庣画澧炲姞璁惧绫诲瀷銆?)
    add_text(doc, "鍦ㄦ櫤鑳藉姪鎵嬭璁′笂锛孲martPromptParser 閫氳繃鍏抽敭璇嶅尮閰嶈瘑鍒Е鍙戞潯浠跺拰鍔ㄤ綔銆傝Е鍙戞潯浠跺寘鎷瘡澶┿€佹瘡鍛ㄣ€佺瀹躲€佸洖瀹躲€佹墜鍔ㄧ瓑绫诲瀷锛涘姩浣滃寘鎷伅鍏夊紑鍏炽€佺┖璋冩俯搴﹁缃€佺獥甯樻瘮渚嬨€佺數瑙嗗紑鍏炽€佸噣鍖栧櫒鍚姩銆佹壂鍦版満鍣ㄤ汉杩愯鍜岄棬閿佸畨闃叉彁绀虹瓑銆傝В鏋愮粨鏋滆缁勭粐涓?SmartPromptDraft锛屽苟杩涗竴姝ヨ浆鍖栦负 AutomationSpec 淇濆瓨鍒拌嚜鍔ㄥ寲鍒楄〃銆?)
    add_table(
        doc,
        ["椤甸潰/鍔熻兘", "鍏抽敭鐘舵€佹垨鏁版嵁", "浜や簰缁撴灉"],
        [
            ["棣栭〉涓帶", "activeTab銆乺ooms銆乻cenes銆乮sNight", "灞曠ず绌洪棿鍏ュ彛銆佸満鏅揩鎹峰叆鍙ｅ拰鏃ュ鑳屾櫙銆?],
            ["鎴块棿鐐逛綅", "activeRoomId銆乺oomDevices銆乻electedPointId", "绛涢€夊綋鍓嶆埧闂村凡瀹夎璁惧锛屽苟鏄剧ず鍙偣鍑荤偣浣嶃€?],
            ["璁惧璇︽儏", "detailPointId銆乧urrentValue銆乸owerOn銆乤utoManaged", "鎵撳紑璇︽儏闈㈡澘锛岃皟鏁磋澶囧弬鏁板苟鍙嶉鎸囨爣鍙樺寲銆?],
            ["鏅鸿兘鍔╂墜", "agentPrompt銆乧hatMessages銆乤gentThinking", "杈撳叆鎸囦护鍚庣敓鎴愬洖澶嶃€佽崏绋垮拰鑷姩鍖栧姩浣溿€?],
            ["鑷姩鍖栬剼鏈?, "automations銆乪xpandedAutomationId", "灞曠ず鑴氭湰鍒楄〃锛屾敮鎸佸睍寮€鏌ョ湅瑙﹀彂鏉′欢鍜屽姩浣溿€?],
        ],
        [3.0, 5.2, 6.8],
    )

    add_heading_cn(doc, "4.1.5 缂栫爜瀹炵幇", 3)
    add_text(doc, "鏈」鐩殑缂栫爜閲嶇偣鏄?ArkTS 澹版槑寮?UI銆佺姸鎬侀┍鍔ㄤ氦浜掑拰鏅鸿兘鎸囦护瑙ｆ瀽銆備笅闈㈤€夊彇椤圭洰涓殑鏍稿績瀹炵幇鎬濇兂杩涜璇存槑銆?)
    add_text(doc, "绗竴锛屾埧闂村浘鐗囨牴鎹棩澶滄ā寮忓拰鐏厜鐘舵€佸姩鎬佸垏鎹€傜郴缁熼€氳繃褰撳墠鎴块棿銆佹槸鍚﹀闂淬€佺伅鍏夋槸鍚﹀紑鍚笁涓潯浠堕€夋嫨瀵瑰簲璧勬簮锛屼娇鐢ㄦ埛鍦ㄨ瑙変笂鐩存帴鎰熺煡鎴块棿鐘舵€併€?)
    add_code(doc, """
private roomImageById(roomId: string): Resource {
  const room = this.roomById(roomId);
  if (room.images === undefined) {
    return $r('app.media.room_living_day_lightoff');
  }
  const lightOn = this.lightOnForRoom(roomId);
  if (this.isNight) {
    return lightOn ? room.images!.nightLightOn : room.images!.nightLightOff;
  }
  return lightOn ? room.images!.dayLightOn : room.images!.dayLightOff;
}
""")
    add_text(doc, "绗簩锛岃澶囪鎯呯粍浠堕€氳繃 pointId 鑾峰彇閰嶇疆椤癸紝閬垮厤涓烘瘡涓澶囬噸澶嶇紪鍐欏畬鏁撮〉闈€傝澶囨爣棰樸€佸浘鐗囥€佹寚鏍囥€佹帶鍒舵粦鍧楀拰鍔ㄤ綔鍒楄〃鍧囨潵鑷?DevicePageSpec锛屽疄鐜颁簡閰嶇疆椹卞姩鐨勯〉闈㈠鐢ㄣ€?)
    add_code(doc, """
private page(): DevicePageSpec {
  for (let i = 0; i < DEVICE_PAGES.length; i++) {
    if (DEVICE_PAGES[i].id === this.pointId) {
      return DEVICE_PAGES[i];
    }
  }
  return DEVICE_PAGES[0];
}
""")
    add_text(doc, "绗笁锛屾櫤鑳藉姪鎵嬮噰鐢ㄦ湰鍦拌鍒欎紭鍏堢殑绛栫暐銆傚浜庢櫤鑳藉灞呯浉鍏虫寚浠わ紝绯荤粺涓嶄緷璧栧閮ㄥぇ妯″瀷锛岃€屾槸鐩存帴璋冪敤鏈湴瑙ｆ瀽鍣ㄧ敓鎴愮粨鏋勫寲鑽夌锛涘浜庢櫘閫氶棶绛旓紝鍐嶈皟鐢?DeepSeek 鏈嶅姟銆傝繖鏍锋棦鎻愰珮浜嗗灞呮帶鍒跺満鏅殑绋冲畾鎬э紝涔熼檷浣庝簡缃戠粶涓嶅彲鐢ㄦ椂鐨勫奖鍝嶃€?)
    add_code(doc, """
export async function resolveSmartAssistantPrompt(prompt: string): Promise<SmartAssistantReply> {
  if (shouldUseLocalSmartHome(prompt)) {
    const draft = parseSmartPrompt(prompt);
    return {
      mode: 'smart_home',
      title: draft.shouldCreateAutomation ? '鏅鸿兘鍔╂墜宸茬敓鎴愯嚜鍔ㄥ寲鑽夌' : '鏅鸿兘鍔╂墜宸茬敓鎴愭墽琛屾柟妗?,
      detail: draft.response,
      draft: draft
    };
  }
  const answer = await askDeepSeek(prompt);
  return { mode: 'llm', title: 'DeepSeek', detail: answer };
}
""")
    add_text(doc, "绗洓锛岃嚜鍔ㄥ寲鑴氭湰浣跨敤缁熶竴鎺ュ彛鎻忚堪瑙﹀彂鏉′欢鍜屽姩浣溿€傝繖鏍锋棤璁鸿剼鏈潵鑷郴缁熼粯璁ゃ€佺敤鎴锋墜鍔ㄥ垱寤鸿繕鏄櫤鑳藉姪鎵嬭В鏋愶紝閮藉彲浠ュ湪鍚屼竴鍒楄〃涓睍绀哄拰绠＄悊銆?)
    add_table(
        doc,
        ["鎺ュ彛", "瀛楁", "浣滅敤"],
        [
            ["SmartTriggerSpec", "type銆乴abel銆乼ime銆亀eekday銆乻ceneId銆乺oomId", "鎻忚堪鏃堕棿銆佹瘡鍛ㄣ€佺瀹躲€佸洖瀹躲€佸満鏅瓑瑙﹀彂鏉′欢銆?],
            ["SmartActionSpec", "pointId銆乧ommand銆乴abel銆乿alue", "鎻忚堪璁惧銆佸懡浠ゃ€佹樉绀烘枃鏈拰鍙傛暟鍊笺€?],
            ["AutomationSpec", "id銆乼itle銆乼rigger銆乤ction銆乻ource銆乪nabled", "鎻忚堪瀹屾暣鑷姩鍖栬剼鏈強鍏舵潵婧愬拰鍚敤鐘舵€併€?],
            ["AgentMessageSpec", "id銆乺ole銆乼ext銆乵eta", "鎻忚堪鏅鸿兘鍔╂墜鑱婂ぉ娑堟伅銆?],
        ],
        [3.0, 5.6, 6.4],
    )

    add_heading_cn(doc, "4.1.6 浠ｇ爜娴嬭瘯", 3)
    add_text(doc, "娴嬭瘯鐨勭洰鏍囨槸纭绯荤粺涓昏椤甸潰鑳藉姝ｅ父灞曠ず锛岃澶囩偣浣嶅拰璇︽儏鎺у埗鑳藉鍝嶅簲锛屾櫤鑳藉姪鎵嬭兘澶熸妸鍏稿瀷涓枃鎸囦护瑙ｆ瀽鎴愭纭姩浣滐紝璧勬簮鏂囦欢鑳藉姝ｅ父鍔犺浇锛岄」鐩湪寮€鍙戠幆澧冧腑鑳藉鏋勫缓杩愯銆傛祴璇曟柟娉曚互鎵嬪伐鍔熻兘娴嬭瘯鍜屼唬鐮侀€昏緫妫€鏌ヤ负涓伙紝缁撳悎椤圭洰鍐呭崟鍏冩祴璇曠洰褰曡繘琛屽熀纭€楠岃瘉銆?)
    add_table(
        doc,
        ["娴嬭瘯缂栧彿", "娴嬭瘯鍐呭", "鎿嶄綔姝ラ", "棰勬湡缁撴灉", "缁撴灉"],
        [
            ["T01", "棣栭〉鍔犺浇", "鍚姩搴旂敤杩涘叆棣栭〉銆?, "鏄剧ず绌洪棿涓帶鑳屾櫙銆佹埧闂村叆鍙ｃ€佸簳閮ㄥ鑸€?, "閫氳繃"],
            ["T02", "鎴块棿鍒囨崲", "鍦ㄥ鍘呬笌鍗у涔嬮棿鍒囨崲銆?, "鐐逛綅鍒楄〃鍜屾埧闂村浘鐗囬殢 activeRoomId 鏇存柊銆?, "閫氳繃"],
            ["T03", "鐏厜鐘舵€?, "鐐瑰嚮鐏厜鎺у埗骞跺垏鎹㈡棩澶滄ā寮忋€?, "鎴块棿鍥剧墖鍦ㄧ伅寮€/鐏叧銆佹棩闂?澶滈棿涔嬮棿鍒囨崲銆?, "閫氳繃"],
            ["T04", "璁惧璇︽儏", "鐐瑰嚮绌鸿皟銆佺獥甯樸€佸噣鍖栧櫒绛夌偣浣嶃€?, "寮瑰嚭璇︽儏椤碉紝灞曠ず鎸囨爣銆佹粦鍧楀拰璁惧鑳藉姏銆?, "閫氳繃"],
            ["T05", "婊戝潡鎺у埗", "鎷栧姩娓╁害銆佷寒搴︺€佺獥甯樻瘮渚嬫粦鍧椼€?, "褰撳墠鍊煎拰鐩稿叧鎸囨爣鏂囨湰鍚屾鍙樺寲銆?, "閫氳繃"],
            ["T06", "鏅鸿兘鎸囦护", "杈撳叆鈥滄瘡澶?2:30鍏抽棴瀹㈠巺鐏苟鎷変笂鍗у绐楀笜鈥濄€?, "鐢熸垚鏃堕棿瑙﹀彂鑴氭湰鍜屽搴旇澶囧姩浣溿€?, "閫氳繃"],
            ["T07", "鑷姩鍖栧睍寮€", "灞曞紑绂诲鏂數鎴栫潯鐪犺剼鏈€?, "鏄剧ず瑙﹀彂鏉′欢銆佸姩浣滃垪琛ㄥ拰鍚敤鐘舵€併€?, "閫氳繃"],
            ["T08", "寮傚父闄嶇骇", "鏈厤缃?DeepSeek API Key 鏃惰緭鍏ユ櫘閫氶棶绛斻€?, "鎻愮ず闇€瑕侀厤缃?API Key锛屼笉褰卞搷鏈湴瀹跺眳鎸囦护瑙ｆ瀽銆?, "閫氳繃"],
        ],
        [1.5, 2.6, 4.5, 4.5, 1.5],
    )
    add_text(doc, "娴嬭瘯杩囩▼涓彂鐜帮紝椤圭洰婧愭枃浠朵腑鐨勯儴鍒嗕腑鏂囧唴瀹瑰湪褰撳墠鏌ョ湅鐜涓嚭鐜扮紪鐮佹樉绀哄紓甯革紝浣嗛」鐩粨鏋勩€佽祫婧愬紩鐢ㄥ拰鐘舵€侀€昏緫浠嶇劧娓呮櫚銆傚悗缁嫢杩涘叆姝ｅ紡鍙戝竷闃舵锛屽簲缁熶竴妫€鏌ユ枃浠剁紪鐮佸拰瀛楃涓叉樉绀烘晥鏋滐紝閬垮厤鍦ㄤ笉鍚屽伐鍏烽摼涔嬮棿鍑虹幇涓枃涔辩爜闂銆?)

    add_heading_cn(doc, "4.1.7 閮ㄧ讲杩愯", 3)
    add_text(doc, "椤圭洰閮ㄧ讲杩愯渚濊禆 HarmonyOS/DevEco Studio 寮€鍙戠幆澧冦€傚伐绋嬫牴鐩綍鍖呭惈 build-profile.json5銆乷h-package.json5銆乭vigorfile.ts銆乪ntry 妯″潡鍜岃祫婧愭枃浠讹紝绗﹀悎楦胯挋搴旂敤椤圭洰缁勭粐鏂瑰紡銆傞儴缃叉椂鍙湪 DevEco Studio 涓墦寮€ SmartHome 宸ョ▼锛屽畬鎴?SDK 涓庣鍚嶉厤缃悗锛岄€夋嫨妯℃嫙鍣ㄦ垨鐪熸満璁惧杩愯 entry 妯″潡銆?)
    add_text(doc, "杩愯缁撴灉鏂归潰锛屽簲鐢ㄨ兘澶熻繘鍏?SmartHome 棣栭〉锛屽睍绀哄搴┖闂翠腑鎺э紱鐢ㄦ埛鍙互鍦ㄥ簳閮ㄥ鑸腑杩涘叆鏅鸿兘鍔╂墜椤甸潰锛屽湪棣栭〉閫夋嫨鎴块棿骞舵墦寮€璁惧璇︽儏銆傞」鐩祫婧愪腑鍖呭惈鎴块棿鐘舵€佸浘銆佽澶囧浘銆?D 妯″瀷鍜?Kenney CC0 璁稿彲璇存槑锛屼究浜庡悗缁户缁墿灞曚负鏇村畬鏁寸殑鏅鸿兘瀹跺眳鍙鍖栨帶鍒跺彴銆?)

    add_heading_cn(doc, "4.2 鑱屼笟瑙勫垝涓庡氨涓氭寚瀵?, 2)
    add_text(doc, "杩欐椤圭洰璁╂垜瀵瑰矖浣嶅垎宸ユ湁浜嗘洿鍏蜂綋鐨勫垽鏂€傞缚钂欏簲鐢ㄥ紑鍙戝苟涓嶆槸鍙啓 UI锛屽緢澶氭椂闂翠細鑺卞湪鐘舵€佹媶鍒嗐€佺粍浠惰竟鐣屻€佽祫婧愰€傞厤鍜屼氦浜掔粏鑺備笂锛涙櫤鑳界粓绔柟鍚戜篃涓嶅彧鏄‖浠惰繛鎺ワ紝杩樿鎶婅澶囪兘鍔涙娊璞℃垚鐢ㄦ埛鑳界悊瑙ｇ殑鍔ㄤ綔锛涙祴璇曞矖浣嶅垯闇€瑕佹妸鈥滄垜瑙夊緱娌￠棶棰樷€濆彉鎴愬彲澶嶇幇鐨勭敤渚嬪拰缁撴灉銆?)
    add_text(doc, "缁撳悎杩欐 SmartHome 鐨勫畬鎴愯繃绋嬶紝鎴戞洿鍊惧悜浜庝粠绉诲姩绔垨鏅鸿兘缁堢搴旂敤寮€鍙戞柟鍚戝垏鍏ャ€傚悗缁垜闇€瑕佽ˉ寮虹殑涓嶆槸鏌愪竴涓娉曠偣锛岃€屾槸涓€鏁村宸ョ▼鑳藉姏锛氳兘鎶婇渶姹傛媶鎴愭暟鎹ā鍨嬶紝鑳借椤甸潰鐘舵€佷笉娣蜂贡锛岃兘涓哄紓甯告儏鍐电暀涓嬮檷绾ф柟妗堬紝鑳界敤娴嬭瘯鐢ㄤ緥璇佹槑鍔熻兘鍙潬銆傝亴涓氳鍒掍笂锛屾垜甯屾湜鍏堟妸楦胯挋搴旂敤寮€鍙戝拰 TypeScript 鍩虹鎵撶墷锛屽啀閫愭鎵╁睍鍒版櫤鑳藉灞呫€丄I 鍔╂墜浜や簰鍜岀墿鑱旂綉搴旂敤缁煎悎寮€鍙戙€?)

    add_heading_cn(doc, "浜斻€佷笓涓氬疄涔犳€荤粨")
    add_heading_cn(doc, "5.1 鍙傚姞瀹炰範鍜屽畬鎴愪换鍔＄殑鍩烘湰鎯呭喌", 2)
    add_text(doc, "鏈瀹炰範鏈熼棿锛屾垜鍥寸粫 SmartHome 椤圭洰瀹屾垚浜嗕竴娆＄浉瀵瑰畬鏁寸殑寮€鍙戦棴鐜€傛渶鍒濇垜鍙兂鍋氫竴涓櫤鑳藉灞呴椤碉紝浣嗛殢鐫€鍔熻兘鎺ㄨ繘锛岄€愭笎琛ュ嚭浜嗘埧闂村垏鎹€佽澶囩偣浣嶃€佽鎯呭脊灞傘€佹櫤鑳藉姪鎵嬪拰鑷姩鍖栬剼鏈鐞嗙瓑鍐呭銆傝繖涓繃绋嬭鎴戝彂鐜帮紝椤圭洰澶嶆潅搴﹀線寰€涓嶆槸绐佺劧澧炲姞鐨勶紝鑰屾槸鍦ㄤ竴涓釜鈥滃皬鍔熻兘鈥濅箣闂寸殑鐘舵€佸叧绯讳腑鎱㈡參绱Н銆?)
    add_text(doc, "浠庢妧鑳芥帉鎻＄湅锛屾垜瀵?ArkTS 澹版槑寮?UI銆丂State 鐘舵€佸埛鏂般€丂Prop 鍜?@Link 浼犲€笺€佽祫婧愬紩鐢ㄣ€丅uilder 鎷嗗垎鍜屽垪琛ㄦ覆鏌撴湁浜嗘洿鐩存帴鐨勭悊瑙ｃ€傛瘮濡?DeviceDetailPages 缁勪欢鏍规嵁 pointId 璇诲彇閰嶇疆锛岃繖姣旂粰姣忎釜璁惧鍗曠嫭鍐欓〉闈㈡洿瀹规槗缁存姢锛涙埧闂村浘鐗囨牴鎹棩澶滃拰鐏厜鐘舵€佸垏鎹紝涔熻鎴戜綋浼氬埌鐘舵€佸彉閲忓懡鍚嶅拰杈圭晫鍒ゆ柇鐨勯噸瑕佹€с€?)
    add_text(doc, "鍦ㄨ鑼冩柟闈紝鎴戣璇嗗埌浼佷笟鐮斿彂闇€瑕侀噸瑙嗕唬鐮佸彲璇绘€с€佹ā鍧楄竟鐣屻€佸紓甯稿鐞嗐€佺敤鎴蜂綋楠屻€佺増鏉冭鍙拰鍥㈤槦鍗忎綔銆備緥濡傛湰椤圭洰浣跨敤鐨勫鍏锋ā鍨嬭祫婧愭潵鑷?Kenney Furniture Kit 2.0锛屽苟鍦?rawfile 鐩綍涓繚鐣欎簡 CC0 璁稿彲璇存槑锛岃繖浣撶幇浜嗚蒋浠跺紑鍙戜腑鐨勭増鏉冩剰璇嗗拰鍚堣鎰忚瘑銆?)

    add_heading_cn(doc, "5.2 璁＄畻鏈烘妧鏈绀句細銆佸仴搴枫€佸畨鍏ㄣ€佹硶寰嬪強鏂囧寲鐨勫奖鍝?, 2)
    add_text(doc, "缁撳悎 SmartHome 椤圭洰锛屾垜瀵硅绠楁満鎶€鏈殑绀句細褰卞搷鏈変簡鏇村叿浣撶殑鎰熷彈銆傛櫤鑳藉灞呯湅璧锋潵鏄帶鍒剁伅銆佺┖璋冦€佺獥甯樿繖浜涘皬浜嬶紝浣嗗畠瀹為檯杩涘叆鐨勬槸瀹跺涵绌洪棿銆傜郴缁熺煡閬撶敤鎴蜂粈涔堟椂鍊欏洖瀹躲€佷粈涔堟椂鍊欑潯瑙夈€佸摢浜涜澶囧父寮€銆佸摢浜涙埧闂存湁浜烘椿鍔紝杩欎簺淇℃伅濡傛灉澶勭悊涓嶅綋锛屽氨浼氫粠渚垮埄鍔熻兘鍙樻垚闅愮椋庨櫓銆?)
    add_text(doc, "鍥犳锛屾櫤鑳藉灞呰蒋浠剁爺鍙戜笉鑳藉彧杩芥眰鈥滃姛鑳藉鈥濄€傚湪鍋ュ悍鏂归潰锛岀┖璋冦€佺収鏄庡拰绌烘皵鍑€鍖栧櫒鐨勬帶鍒跺簲閬垮厤杩囧害鑷姩鍖栧鑷翠笉閫傦紱鍦ㄥ畨鍏ㄦ柟闈紝闂ㄩ攣銆佺瀹舵柇鐢电瓑鍔熻兘蹇呴』鏈夋槑纭彁绀哄拰纭鏈哄埗锛涘湪娉曞緥鏂归潰锛岄噰闆嗗拰浣跨敤瀹跺涵鏁版嵁搴旈伒瀹堥殣绉佷繚鎶よ姹傦紱鍦ㄦ枃鍖栨柟闈紝涓嶅悓瀹跺涵鐨勭敓娲讳範鎯笉鍚岋紝绯荤粺搴斿厑璁哥敤鎴蜂繚鐣欐墜鍔ㄦ帶鍒舵潈锛岃€屼笉鏄敤缁熶竴瑙勫垯鏇夸唬浜虹殑鍒ゆ柇銆?)

    add_heading_cn(doc, "5.3 搴旂敤绯荤粺鐮斿彂瀵圭幆澧冧繚鎶ゅ拰鍙寔缁彂灞曠殑褰卞搷", 2)
    add_text(doc, "璁＄畻鏈哄簲鐢ㄧ郴缁熸棦浼氭秷鑰楄兘婧愶紝涔熻兘澶熷府鍔╃ぞ浼氭彁鍗囪祫婧愬埄鐢ㄦ晥鐜囥€傛櫤鑳藉灞呯郴缁熷鏋滆璁″悎鐞嗭紝鍙互閫氳繃绂诲鏂數銆佸畾鏃跺叧闂収鏄庛€佺┖璋冩俯搴︿紭鍖栥€佺┖姘斿噣鍖栧櫒鑷姩璋冭妭绛夋柟寮忓噺灏戜笉蹇呰鐨勮兘鑰椼€傛湰椤圭洰涓殑鈥滅瀹舵柇鐢碘€濃€滃闂村叆鐫♀€濃€滃洖瀹舵ā寮忊€濃€滃懆鏈竻娲佲€濈瓑鑷姩鍖栬剼鏈師鍨嬶紝浣撶幇浜嗗簲鐢ㄨ蒋浠跺湪瀹跺涵鑺傝兘鍦烘櫙涓殑浠峰€笺€?)
    add_text(doc, "鍦ㄨ蒋浠跺紑鍙戣繃绋嬩腑锛屼篃搴旀敞鎰忓彲鎸佺画鍙戝睍銆備緥濡傚噺灏戞棤鎰忎箟鍔ㄧ敾鍜岄珮璐熻浇娓叉煋锛屾帶鍒剁綉缁滆姹傞鐜囷紝閬垮厤閲嶅涓嬭浇璧勬簮锛屽悎鐞嗗帇缂╁浘鐗囧拰妯″瀷鏂囦欢锛屽欢闀胯澶囦娇鐢ㄥ鍛姐€傚宸ョ▼甯堣€岃█锛屽彲鎸佺画涓嶆槸鎶借薄鍙ｅ彿锛岃€屾槸浣撶幇鍦ㄦ瘡涓€娆℃妧鏈€夊瀷銆佹€ц兘浼樺寲鍜岀敤鎴峰紩瀵间箣涓€?)

    add_heading_cn(doc, "5.4 宸ョ▼瀹炶返涓殑鑱屼笟閬撳痉涓庤鑼?, 2)
    add_text(doc, "宸ョ▼瀹炶返涓殑鑱屼笟閬撳痉鏈€缁堜細钀藉埌寰堝叿浣撶殑浜嬫儏涓娿€傚啓鎶ュ憡鏃朵笉鑳芥妸妯℃澘鏂囧瓧鐓ф惉鎴愯嚜宸辩殑缁忓巻锛屽啓浠ｇ爜鏃朵笉鑳芥妸娌℃湁楠岃瘉杩囩殑鍔熻兘璇存垚宸茬粡绋冲畾锛屼娇鐢ㄧ礌鏉愭椂涓嶈兘蹇界暐璁稿彲璇侊紝娑夊強鐢ㄦ埛鏁版嵁鏃朵笉鑳戒负浜嗘柟渚胯皟璇曡€岄殢鎰忎繚瀛樻晱鎰熶俊鎭€傝繖浜涚湅浼肩粏鑺傦紝鍏跺疄鍐冲畾浜嗕竴涓伐绋嬪笀鏄惁鍙潬銆?)
    add_text(doc, "鍦?SmartHome 椤圭洰涓紝鎴戠壒鍒敞鎰忓埌涓ょ被璐ｄ换锛氫竴绫绘槸鍚堣璐ｄ换锛屼緥濡傞」鐩唴浣跨敤 Kenney 瀹跺叿妯″瀷璧勬簮鏃朵繚鐣?CC0 璁稿彲璇存槑锛涘彟涓€绫绘槸瀹夊叏璐ｄ换锛屼緥濡傝嚜鍔ㄥ寲鑴氭湰铏界劧鍙槸妯℃嫙锛屼絾濡傛灉鏀惧埌鐪熷疄瀹跺涵鍦烘櫙锛岀瀹舵柇鐢点€佸闂撮棬閿佹彁閱掋€佺┖璋冩俯搴﹁皟鑺傞兘鍙兘褰卞搷鐢ㄦ埛鐢熸椿銆傚洜姝ゅ伐绋嬪笀蹇呴』鎶婃祴璇曘€佹彁绀恒€佹潈闄愬拰寮傚父澶勭悊褰撴垚绯荤粺鐨勪竴閮ㄥ垎锛岃€屼笉鏄渶鍚庤ˉ涓婄殑瑁呴グ銆?)

    add_heading_cn(doc, "5.5 宀椾綅闇€姹傘€佽兘鍔涘樊璺濅笌浠婂悗鍔姏鏂瑰悜", 2)
    add_text(doc, "浠庝紒涓氬矖浣嶉渶姹傜湅锛岃蒋浠跺紑鍙戝矖浣嶆櫘閬嶈姹傛墡瀹炵殑缂栫▼鍩虹銆佸伐绋嬪寲宸ュ叿浣跨敤鑳藉姏銆佽壇濂界殑闂鍒嗘瀽鑳藉姏鍜屽洟闃熷崗浣滆兘鍔涖€傜Щ鍔ㄧ鍜岄缚钂欐柟鍚戣繕瑕佹眰鎺屾彙澹版槑寮?UI銆佽法绔€傞厤銆佹€ц兘浼樺寲銆佺粍浠跺寲璁捐鍜岀敤鎴蜂綋楠岋紱鏅鸿兘缁堢鏂瑰悜瑕佹眰鐞嗚В鎿嶄綔绯荤粺銆佺綉缁滈€氫俊銆佺‖浠舵帴鍙ｅ拰璁惧鑱斿姩锛汚I 搴旂敤鏂瑰悜鍒欒姹傜悊瑙ｆā鍨嬫帴鍙ｈ皟鐢ㄣ€佹彁绀鸿瘝璁捐銆佺粨鏋滄牎楠屽拰涓氬姟鍦烘櫙钀藉湴銆?)
    add_text(doc, "瀵圭収杩欎簺瑕佹眰锛屾垜涔熺湅鍒颁簡鑷韩宸窛銆傜涓€锛岀郴缁熸灦鏋勮兘鍔涗粛闇€鍔犲己锛岀洰鍓嶆洿澶氬叧娉ㄥ姛鑳藉疄鐜帮紝瀵瑰彲缁存姢鏋舵瀯銆佹暟鎹寔涔呭寲鍜屽紓甯告仮澶嶈€冭檻涓嶈冻锛涚浜岋紝娴嬭瘯鑳藉姏闇€瑕佹彁鍗囷紝鍚庣画搴斿涔犲崟鍏冩祴璇曘€乁I 鑷姩鍖栨祴璇曞拰鎸佺画闆嗘垚锛涚涓夛紝搴曞眰鐭ヨ瘑浠嶉渶宸╁浐锛屽挨鍏舵槸鎿嶄綔绯荤粺銆佺綉缁滃崗璁€佽澶囬€氫俊鍜屾€ц兘璋冧紭锛涚鍥涳紝宸ョ▼鏂囨。鍜屽洟闃熷崗浣滅粡楠岃繕闇€瑕佸湪鐪熷疄椤圭洰涓户缁Н绱€?)
    add_text(doc, "涓嬩竴闃舵鎴戜細鎶婂姫鍔涙柟鍚戣惤鍒板嚑涓彲鎵ц鐨勭洰鏍囦笂锛氱涓€锛岀户缁畬鍠?SmartHome 椤圭洰锛屾妸褰撳墠妯℃嫙鐘舵€侀€愭鏀归€犳垚鏇存竻鏅扮殑鏁版嵁灞傦紝骞惰ˉ鍏呮湰鍦板瓨鍌紱绗簩锛岀郴缁熷涔?HarmonyOS/ArkTS锛岄噸鐐硅ˉ榻愮敓鍛藉懆鏈熴€佽矾鐢便€佺綉缁滆姹傚拰鎬ц兘浼樺寲锛涚涓夛紝鎶婃祴璇曚粠鎵嬪伐鐐瑰嚮鎵╁睍鍒版洿瑙勮寖鐨勭敤渚嬭褰曞拰鑷姩鍖栭獙璇侊紱绗洓锛岀户缁粌涔?Git 鍒嗘敮绠＄悊銆佹彁浜よ鏄庡拰椤圭洰鏂囨。銆傛垜鐨勭洰鏍囦笉鏄煭鏃堕棿鍐呭爢寰堝鍔熻兘锛岃€屾槸鎶婁竴涓」鐩仛寰楁洿绋炽€佹洿娓呮銆佹洿鍍忕湡瀹炲伐绋嬨€?)

    doc.save(OUT)
    print(OUT)


if __name__ == "__main__":
    build()

