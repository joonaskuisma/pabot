import xml.etree.ElementTree as ET
import pandas as pd
import re
from datetime import datetime, timedelta
import plotly.express as px
import os

def generate_pabot_analysis(outs_dir, pabot_args, options):
    """
    Generate a Pabot execution analysis report from the Robot Framework
    output.xml file.

    The report visualizes executor timelines, usage statistics, and
    parallel execution efficiency using Plotly.

    Analysis can either be embedded into an existing log.html (embed mode)
    or written as a separate HTML file (separate mode). In 'none' mode,
    no analysis is generated.

    Parameters
    ----------
    outs_dir : str
        Directory where Pabot should write analysis output (always pabot_results).

    pabot_args : dict
        Parsed Pabot arguments. Expected structure:

            {
                "analysis": {
                    "mode": "none" | "embed" | "separate",
                    "plotly": "online" | "offline"
                }
            }

    options : dict
        Robot Framework execution options used by Pabot. Expected keys:

            - "outputdir" : str, optional, default "."
                Directory where output.xml/log.html are located.
            - "output" : str, optional, default "output.xml"
                Output XML filename.
            - "log" : str, optional, default "log.html"
                Log HTML filename.

    Returns
    -------
    str | None
        Path to the written HTML file:

        - embed mode: returns the path to the modified log.html
        - separate mode: returns the path to pabot_analysis.html inside outs_dir
        - none or failure: returns None
    """

    analysis = pabot_args.get("analysis", {})
    mode = analysis.get("mode", "none")
    plotly_mode = analysis.get("plotly", "online")

    if mode == "none":
        return None

    # --------------------------
    # Ensure analysis output directory exists
    # --------------------------
    os.makedirs(outs_dir, exist_ok=True)  # always pabot_results

    # --------------------------
    # Resolve Robot Framework outputdir and filenames
    # --------------------------
    rf_output_dir = options.get("outputdir", ".")  # where RF put output.xml/log.html
    xml_file_opt = options.get("output", "output.xml")
    xml_file = xml_file_opt if os.path.isabs(xml_file_opt) else os.path.join(rf_output_dir, xml_file_opt)
    xml_file = os.path.normpath(xml_file)

    if not os.path.exists(xml_file):
        return None

    log_input = None
    if mode == "embed":
        log_file_opt = options.get("log", "log.html")
        log_input = log_file_opt if os.path.isabs(log_file_opt) else os.path.join(rf_output_dir, log_file_opt)
        log_input = os.path.normpath(log_input)

    if mode == "none":
        return None

    if mode not in ("embed", "separate"):
        return None

    # --------------------------
    # Helpers
    # --------------------------
    def parse_time(start_str, elapsed):
        start = datetime.fromisoformat(start_str)
        return start, start + timedelta(seconds=float(elapsed))

    def extract_process_id(text):
        if not text:
            return None
        m = re.search(r"\(ID:(\d+)\)", text)
        return int(m.group(1)) if m else None

    def get_execution_id(test_elem):
        for tag in test_elem.findall("tag"):
            if tag.text and tag.text.startswith("pabot:execution-ID"):
                return int(tag.text.split(":")[-1])
        return None

    def get_executor_index(test_elem):
        for tag in test_elem.findall("tag"):
            if tag.text and tag.text.startswith("pabot:executor-info:"):
                m = re.search(r"\[(\d+)/\d+\]", tag.text)
                if m:
                    return int(m.group(1))
        return None

    def build_rf_id(suite_stack, test_idx=None, kw_stack=None):
        parts = [f"s{i}" for i in suite_stack]
        if test_idx is not None:
            parts.append(f"t{test_idx}")
        if kw_stack:
            parts.extend([f"k{i}" for i in kw_stack])
        return "-".join(parts)

    # --------------------------
    # Parse XML
    # --------------------------
    tree = ET.parse(xml_file)
    root = tree.getroot()
    records = []

    # Build execution -> executor mapping
    execution_to_executor = {}
    for test in root.findall(".//test"):
        execution_id = get_execution_id(test)
        executor_idx = get_executor_index(test)
        if execution_id is not None and executor_idx is not None:
            execution_to_executor[execution_id] = executor_idx

    # --------------------------
    # Recursive parser
    # --------------------------
    def parse_suite(suite_elem, suite_stack, execution_to_executor, records, sibling_idx=1):
        suite_stack.append(sibling_idx)

        # Suite Setup/Teardown
        for container_idx, container in enumerate(suite_elem.findall("kw"), start=1):
            container_name = container.attrib.get("name", "")
            container_type = None
            if container_name.startswith("Pabot Suite Setup Container"):
                container_type = "Suite Setup"
            elif container_name.startswith("Pabot Suite Teardown Container"):
                container_type = "Suite Teardown"

            if container_type:
                for child_idx, child in enumerate(container.findall("kw"), start=1):
                    status_node = child.find("status")
                    if status_node is None:
                        continue
                    execution_id = extract_process_id(child.attrib.get("name",""))
                    if execution_id is None:
                        continue
                    executor_idx = execution_to_executor.get(execution_id)
                    if executor_idx is None:
                        continue
                    start, end = parse_time(status_node.attrib["start"], status_node.attrib["elapsed"])
                    owner = child.attrib.get("owner") or child.attrib.get("library") or ""
                    rf_id = build_rf_id(suite_stack, None, [container_idx, child_idx])
                    records.append({
                        "Executor": executor_idx,
                        "Process ID": execution_id,
                        "Start": start,
                        "End": end,
                        "Duration": (end - start).total_seconds(),
                        "Name": child.attrib.get("name"),
                        "Level": container_type,
                        "Status": status_node.attrib["status"],
                        "Owner": owner,
                        "RF_ID": rf_id,
                        "Color": 0 if status_node.attrib["status"]=="PASS" else 1 if status_node.attrib["status"]=="FAIL" else 2
                    })

        # Tests
        for test_idx, test in enumerate(suite_elem.findall("test"), start=1):
            execution_id = get_execution_id(test)
            executor_idx = execution_to_executor.get(execution_id)
            if execution_id is None or executor_idx is None:
                continue
            status_node = test.find("status")
            if status_node is None:
                continue
            start, end = parse_time(status_node.attrib["start"], status_node.attrib["elapsed"])
            rf_id = build_rf_id(suite_stack, test_idx, [])
            records.append({
                "Executor": executor_idx,
                "Process ID": execution_id,
                "Start": start,
                "End": end,
                "Duration": (end - start).total_seconds(),
                "Name": test.attrib.get("name"),
                "Level": "Test Body",
                "Status": status_node.attrib["status"],
                "Owner": "",
                "RF_ID": rf_id,
                "Color": 0 if status_node.attrib["status"]=="PASS" else 1 if status_node.attrib["status"]=="FAIL" else 2
            })

        # Subsuites
        for idx, subsuite in enumerate(suite_elem.findall("suite"), start=1):
            parse_suite(subsuite, suite_stack, execution_to_executor, records, sibling_idx=idx)

        suite_stack.pop()

    # Top-level suites
    for idx, top_suite in enumerate(root.findall("suite"), start=1):
        parse_suite(top_suite, suite_stack=[], execution_to_executor=execution_to_executor, records=records, sibling_idx=idx)

    # --------------------------
    # DataFrame
    # --------------------------
    if not records:
        return None
    
    df = pd.DataFrame(records)
    df = df.sort_values(["Executor","Start"])
    executors = sorted(df["Executor"].unique())

    global_start = df["Start"].min()
    global_end = df["End"].max()
    total_time = (global_end - global_start).total_seconds()
    parallel_efficiency = round(100 * df["Duration"].sum() / (len(executors)*total_time),1) if total_time>0 else 0

    # --------------------------
    # Usage Stats
    # --------------------------
    usage_stats=[]
    for e in executors:
        executor_df = df[df["Executor"]==e].sort_values("Start")
        intervals = executor_df[["Start","End"]].values.tolist()
        if len(intervals)>0:
            merged = [list(intervals[0])]
            for interval in intervals[1:]:
                if interval[0]<=merged[-1][1]:
                    merged[-1][1]=max(merged[-1][1],interval[1])
                else:
                    merged.append(list(interval))
            busy=sum((end-start).total_seconds() for start,end in merged)
        else:
            busy=0.0
        usage_pct = round(100*busy/total_time,2) if total_time>0 else 0.0
        usage_stats.append({"Executor":e,"Busy Time (s)":round(busy,2),"Idle Time (s)":round(total_time-busy,2),"Usage %":usage_pct})

    usage_df = pd.DataFrame(usage_stats)

    # --------------------------
    # Extra Metrics
    # --------------------------
    proc_counts=df.groupby("Executor")["Process ID"].nunique().reset_index(name="Unique Processes")
    proc_duration=df.groupby(["Executor","Process ID"])["Duration"].sum().reset_index()
    avg_duration=proc_duration.groupby("Executor")["Duration"].mean().round(2).reset_index(name="Avg Duration (s)")
    fail_counts=df[df["Status"]=="FAIL"].groupby("Executor").size().reset_index(name="Fail Count")

    usage_df=usage_df.merge(proc_counts,on="Executor",how="left")
    usage_df=usage_df.merge(avg_duration,on="Executor",how="left")
    usage_df=usage_df.merge(fail_counts,on="Executor",how="left")
    usage_df["Fail Count"]=usage_df["Fail Count"].fillna(0).astype(int)

    def usage_bar(val):
        return f'<div class="usage-bar-wrapper"><div class="usage-bar" style="width:{val}%"></div><span class="usage-text">{val}%</span></div>'

    usage_df["Usage %"]=usage_df["Usage %"].apply(usage_bar)
    usage_df=usage_df[["Executor","Unique Processes","Busy Time (s)","Idle Time (s)","Usage %","Avg Duration (s)","Fail Count"]]

    # --------------------------
    # Timeline Plot
    # --------------------------
    color_map={"PASS":"#97bd61","FAIL":"#ce3e01","SKIP":"#fed84f"}
    fig = px.timeline(df,
        x_start="Start", x_end="End", y="Executor",
        hover_name="Name",
        hover_data=["Process ID","Level","Duration","Status","RF_ID"],
        custom_data=["RF_ID"],
        color="Status",
        color_discrete_map=color_map,
        pattern_shape="Level",
        pattern_shape_map={"Suite Setup":"/","Suite Teardown":"\\","Test Body":""},
        range_y=(0.5,len(executors)+0.5),
    )

    fig.add_vrect(x0=global_start, x1=global_end, fillcolor="rgba(100,150,255,0.15)", line_width=0)
    fig.update_layout(
        title=dict(text="Executor Timeline (Suite Setup/Teardown & Test Bodies)", x=0.5, xanchor='center', yanchor='top', font=dict(size=14)),
        legend=dict(orientation="h", yanchor="bottom", y=1.005, xanchor="left", x=0),
        margin=dict(l=30,r=20,t=150,b=80),
        height=max(400,len(executors)*50)
    )
    fig.update_xaxes(range=[global_start,global_end])
    fig.update_traces(width=0.75)

    # --------------------------
    # Generate HTML
    # --------------------------
    usage_html=usage_df.to_html(index=False,border=0,classes='pabot-table',table_id='executor-usage-table',escape=False)
    plot_html = fig.to_html(
        full_html=False,
        include_plotlyjs="cdn" if plotly_mode == "online" else True,
        div_id="pabot-timeline"
    )

    analysis_html = f"""
<section id="pabot-analysis">
<h1>Pabot Execution Analysis</h1>

<div class="summary-block">
    <div class="summary-item">
        <div class="summary-label">Total Duration</div>
        <div class="summary-value">{round(total_time,2)} s</div>
    </div>

    <div class="summary-item">
        <div class="summary-label">Total Work</div>
        <div class="summary-value">{round(df['Duration'].sum(),2)} s</div>
    </div>

    <div class="summary-item">
        <div class="summary-label">Parallel Efficiency</div>
        <div class="summary-value">{parallel_efficiency}%</div>
    </div>
</div>
<h2>Executor Usage</h2>
{usage_html}

<h2>Timeline</h2>
<div id="plot-wrapper" class="plot-wrapper">
{plot_html}
</div>

<script>
(function() {{
    const plot = document.getElementById("pabot-timeline");
    if(!plot) return;

    function updateTheme(){{
        const theme = document.body.getAttribute("data-theme") || "light";

        const layoutUpdate = {{
            paper_bgcolor: theme==="dark" ? "#1c2227" : "white",
            plot_bgcolor: theme==="dark" ? "#1c2227" : "white",
            font: {{color: theme==="dark" ? "#e2e1d7" : "black"}},
            'xaxis.color': theme==="dark" ? "#e2e1d7" : "black",
            'xaxis.gridcolor': theme==="dark" ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.1)",
            'yaxis.color': theme==="dark" ? "#e2e1d7" : "black"
        }};
        Plotly.relayout(plot, layoutUpdate);
    }}

    document.addEventListener("DOMContentLoaded", updateTheme);
    new MutationObserver(updateTheme).observe(document.body,{{attributes:true, attributeFilter:["data-theme"]}});
}})();

(function() {{

    function getCellValue(tr, idx) {{
        return tr.children[idx].innerText || tr.children[idx].textContent;
    }}

    function comparer(idx, asc) {{
        return function(a, b) {{
            const v1 = getCellValue(asc ? a : b, idx);
            const v2 = getCellValue(asc ? b : a, idx);

            const n1 = parseFloat(v1.replace('%',''));
            const n2 = parseFloat(v2.replace('%',''));

            if (!isNaN(n1) && !isNaN(n2)) {{
                return n1 - n2;
            }}
            return v1.localeCompare(v2);
        }};
    }}

    function clearSortIndicators(headers) {{
        headers.forEach(th => {{
            th.classList.remove("sort-asc", "sort-desc", "highlight");
        }});
    }}

    function clearColumnHighlight(table) {{
        table.querySelectorAll("td").forEach(td => {{
            td.classList.remove("highlight");
        }});
    }}

    document.addEventListener("DOMContentLoaded", function() {{

        const table = document.getElementById("executor-usage-table");
        const headers = Array.from(table.querySelectorAll("th"));

        headers.forEach((th, idx) => {{

            let asc = false;

            th.addEventListener("click", () => {{

                const tbody = table.querySelector("tbody");

                Array.from(tbody.querySelectorAll("tr"))
                    .sort(comparer(idx, asc))
                    .forEach(tr => tbody.appendChild(tr));

                clearSortIndicators(headers);
                clearColumnHighlight(table);

                th.classList.add(asc ? "sort-asc" : "sort-desc");
                th.classList.add("highlight");

                table.querySelectorAll("tbody tr").forEach(tr => {{
                    tr.children[idx].classList.add("highlight");
                }});

                asc = !asc;
            }});
        }});

        // Default sort
        headers[0].click();
    }});

}})();

const plot = document.getElementById("pabot-timeline");

plot.on('plotly_click', function(e){{

    const rf_id = e.points[0].customdata[0];

    let el = null;

    if(typeof makeElementVisible === "function"){{

        makeElementVisible(rf_id);

        el = document.getElementById(rf_id);

    }} else {{

        el = document.getElementById(rf_id);

    }}

    if(el){{
        el.classList.remove("rf-highlight-init", "rf-highlight-fade");
        void el.offsetWidth;

        el.scrollIntoView({{
            behavior:"smooth",
            block:"center"
        }});

        el.classList.add("rf-highlight-init");

        setTimeout(() => {{
            el.classList.add("rf-highlight-fade");
        }}, 50);

        setTimeout(() => {{
            el.classList.remove("rf-highlight-init", "rf-highlight-fade");
        }}, 10050);

    }}

}});
</script>

<style>
#pabot-analysis {{
    margin-top:2em;
    padding:1em;
    overflow-x: auto;
}}
/* Light/Dark vars */
body[data-theme="dark"] {{
    --bg-color: #1c2227;
    --text-color: #e2e1d7;
    --primary-color: #333;
    --secondary-color: #555;
    --highlight-color: #2a2e33;
}}
body[data-theme="light"] {{
    --bg-color: white;
    --text-color: black;
    --primary-color: #ddd;
    --secondary-color: #ccc;
    --highlight-color: #f9f9f9;
}}
#pabot-analysis h1,h2 {{
    font-family: Helvetica,sans-serif;
    color: var(--text-color);
}}

/* Sort indicators */
#executor-usage-table th {{
    cursor: pointer;
    position: relative;
    padding-right: 20px;
}}
#executor-usage-table th.sort-asc::after {{
    content: "▲";
    position: absolute;
    right: 6px;
}}
#executor-usage-table th.sort-desc::after {{
    content: "▼";
    position: absolute;
    right: 6px;
}}
#executor-usage-table td {{
    vertical-align: middle;
}}
#executor-usage-table th,
#executor-usage-table tbody tr {{
    transition: background-color 0.25s ease;
}}
/* Column highlight - light */
body[data-theme="light"] #executor-usage-table td.highlight,
body[data-theme="light"] #executor-usage-table th.highlight {{
    background-color: rgba(100,150,255,0.15);
}}

/* Column highlight - dark */
body[data-theme="dark"] #executor-usage-table td.highlight,
body[data-theme="dark"] #executor-usage-table th.highlight {{
    background-color: rgba(120,180,255,0.25);
}}

/* Row hover - light */
body[data-theme="light"] #executor-usage-table tbody tr:hover {{
    background-color: rgba(0,0,0,0.05);
}}

/* Row hover - dark */
body[data-theme="dark"] #executor-usage-table tbody tr:hover {{
    background-color: rgba(255,255,255,0.08);
}}

.summary-block {{
    display: flex;
    gap: 1.5em;
    flex-wrap: wrap;
    align-items: flex-start;
    justify-content: flex-start;
    width: 100%;
}}
.summary-item {{
    background-color: var(--highlight-color);
    padding:0.5em 0.8em;
    border-radius:6px;
    flex: 1 1 120px;
    min-width:100px;
    box-sizing: border-box;
}}
.summary-label {{
    font-weight:bold;
    display:block;
    font-size: 0.85em;
    opacity: 0.8;
}}
.summary-value {{
    font-family:monospace;
    font-size: 1.2em;
    font-weight: bold;
    margin-top: 0.2em;
}}
.pabot-table {{
    width:100%;
    border-collapse:collapse;
    margin:0.5em 0;
    table-layout: auto;
    overflow-x: auto;
}}
.pabot-table th,.pabot-table td {{
    padding:0.25em 0.4em;
    font-size:0.9em;
    border:1px solid var(--secondary-color);
    color: var(--text-color);
}}
.pabot-table td:nth-child(5) {{
    width: 400px;
    max-width: 1000px;
}}
.pabot-table th {{
    background-color: var(--primary-color);
    font-weight:bold;
}}
.pabot-table tr:nth-child(even){{
    background-color: var(--highlight-color);
}}
.plot-wrapper {{
    width:100%;
    margin:1em 0;
    overflow: hidden;
}}
.plot-wrapper svg, .plot-wrapper .plotly{{
    width:100% !important;
    height:auto !important;
}}
.usage-bar-wrapper {{
    position: relative;
    height: 22px;
    background-color: var(--secondary-color);
    border-radius: 4px;
    overflow: hidden;
    display: flex;
    align-items: center;
}}

.usage-bar {{
    position: absolute;
    left: 0;
    top: 0;
    height: 100%;
    background-color: #97bd61;
    transition: width 0.4s ease;
}}

.usage-text {{
    position: relative;
    width: 100%;
    text-align: center;
    font-size: 0.75em;
    font-weight: bold;
    z-index: 1;
}}

.rf-highlight-init {{
    background-color: #fff200;
    outline: 2px solid #ffc107;
    box-shadow: 0 0 15px rgba(255,193,7,1);
}}

.rf-highlight-fade {{
    transition: background-color 10s ease, box-shadow 10s ease, outline-color 10s ease;
    background-color: transparent !important;
    box-shadow: none !important;
    outline-color: transparent !important;
}}
</style>
</section>
"""

    # --------------------------
    # Write HTML
    # --------------------------
    if mode == 'embed':  # and log_input and os.path.exists(log_input):
        # EMBED mode
        with open(log_input,"r",encoding="utf-8") as f:
            log_content=f.read()
        if "</body>" in log_content:
            log_content=log_content.replace("</body>",f"{analysis_html}\n</body>")
        else:
            log_content+=analysis_html
        out_file=log_input
        with open(out_file,"w",encoding="utf-8") as f:
            f.write(log_content)
        return os.path.abspath(out_file)
    elif mode == 'separate':
        # SEPARATE mode
        out_file = os.path.join(outs_dir, "pabot_analysis.html")
        with open(out_file,"w",encoding="utf-8") as f:
            f.write(f"""<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Pabot Execution Analysis</title></head><body>{analysis_html}</body></html>""")
        return os.path.abspath(out_file)
    else:
        return None
