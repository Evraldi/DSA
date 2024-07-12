import dash
from dash import dcc, html, Input, Output, State
import plotly.graph_objects as go
import networkx as nx

# Define the Node and CircularLinkedList classes
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class CircularLinkedList:
    def __init__(self):
        self.head = None

    def insert_end(self, data):
        new_node = Node(data)
        if self.head is None:
            self.head = new_node
            new_node.next = self.head
        else:
            temp = self.head
            while temp.next != self.head:
                temp = temp.next
            temp.next = new_node
            new_node.next = self.head

    def remove_end(self):
        if self.head is None:
            return
        elif self.head.next == self.head:
            self.head = None
        else:
            current = self.head
            while current.next.next != self.head:
                current = current.next
            current.next = self.head

    def clear(self):
        self.head = None

    def to_list_with_indices(self):
        result = []
        if self.head is not None:
            temp = self.head
            index = 0
            while True:
                result.append((temp.data, index))
                temp = temp.next
                index += 1
                if temp == self.head:
                    break
        return result

# Initialize the CircularLinkedList
cll = CircularLinkedList()

def create_circular_linked_list_graph(cll):
    G = nx.DiGraph()
    nodes_with_indices = cll.to_list_with_indices()

    if not nodes_with_indices:
        return None, None

    for data, idx in nodes_with_indices:
        G.add_node(f"{data}_{idx}")

    for i in range(len(nodes_with_indices)):
        data, idx = nodes_with_indices[i]
        next_data, next_idx = nodes_with_indices[(i + 1) % len(nodes_with_indices)]
        G.add_edge(f"{data}_{idx}", f"{next_data}_{next_idx}")

    pos = nx.circular_layout(G)
    return G, pos

def plotly_circular_linked_list(cll, highlight_node=None):
    G, pos = create_circular_linked_list_graph(cll)

    if G is None:
        return go.Figure()

    edge_x = []
    edge_y = []
    for edge in G.edges():
        x0, y0 = pos[edge[0]]
        x1, y1 = pos[edge[1]]
        edge_x.append(x0)
        edge_x.append(x1)
        edge_y.append(y0)
        edge_y.append(y1)

    fig = go.Figure()

    # Add edges
    fig.add_trace(go.Scatter(x=edge_x,
                             y=edge_y,
                             mode='lines+markers',
                             line=dict(width=1, color='black'),
                             marker=dict(size=2, color='black'),
                             name='Edges'))

    # Add square nodes
    annotations = []
    node_colors = ['lightblue'] * len(G.nodes())
    nodes_with_indices = cll.to_list_with_indices()
    head_node = nodes_with_indices[0][0] if nodes_with_indices else None
    tail_node = nodes_with_indices[-1][0] if nodes_with_indices else None
    if head_node:
        node_colors[list(G.nodes()).index(f"{head_node}_0")] = 'lightcoral'
    if tail_node:
        node_colors[list(G.nodes()).index(f"{tail_node}_{len(nodes_with_indices) - 1}")] = 'lightyellow'

    if highlight_node:
        node_colors[list(G.nodes()).index(highlight_node)] = 'lightgreen'

    for node, color in zip(G.nodes(), node_colors):
        x, y = pos[node]
        annotations.append(dict(
            x=x, y=y,
            xref='x', yref='y',
            text=node.split('_')[0],  # Display only the data part
            showarrow=False,
            font=dict(color='black', size=14),
            align='center',
            valign='middle',
            bordercolor='black',
            borderwidth=2,
            bgcolor=color,
            ax=0,
            ay=0,
            width=40,  # Width of the square node
            height=40  # Height of the square node
        ))

    fig.add_trace(go.Scatter(
        x=[pos[node][0] for node in G.nodes()],
        y=[pos[node][1] for node in G.nodes()],
        mode='markers',
        marker=dict(size=0),  # Hide the default markers
        text=[node.split('_')[0] for node in G.nodes()],
        hoverinfo='text'
    ))

    fig.update_layout(
        annotations=annotations,
        title='Circular Linked List Visualization',
        showlegend=False,
        xaxis=dict(showgrid=False, zeroline=False),
        yaxis=dict(showgrid=False, zeroline=False),
        plot_bgcolor='white'
    )

    return fig

# Define the function to update node information
def update_info(_):
    nodes = cll.to_list_with_indices()
    if nodes:
        head_node = nodes[0][0]
        tail_node = nodes[-1][0]
        info = f'Current Nodes: {[data for data, idx in nodes]}\nHead: {head_node}\nTail: {tail_node}'
    else:
        info = 'The list is empty.'
    return info

# Define the function to update traversal information
def update_traversal_info(speed, current_node=None):
    if current_node:
        return f'Traversal Speed: {speed}x\nCurrent Node: {current_node}'
    return f'Traversal Speed: {speed}x'

# Initialize the Dash app
app = dash.Dash(__name__)

app.layout = html.Div([
    dcc.Graph(id='graph', style={'height': '60vh'}),
    html.Button('Add Node', id='add-node', n_clicks=0),
    html.Button('Remove Node', id='remove-node', n_clicks=0),
    html.Button('Clear List', id='clear-list', n_clicks=0),
    dcc.Input(id='node-value', type='number', placeholder='Enter node value'),
    html.Button('Start Traversal', id='start-traversal', n_clicks=0),
    dcc.Interval(id='interval-component', interval=1000, n_intervals=0, disabled=True),
    dcc.Slider(id='speed-slider', min=0.5, max=3, step=0.1, value=1, marks={i: f"{i}x" for i in range(1, 4)}),
    html.Div(id='node-info'),
    html.Div(id='traversal-info', style={'margin-top': '20px'}),
])

@app.callback(
    Output('graph', 'figure'),
    Output('node-info', 'children'),
    Output('interval-component', 'disabled'),
    Output('interval-component', 'interval'),
    Output('traversal-info', 'children'),
    Input('add-node', 'n_clicks'),
    Input('remove-node', 'n_clicks'),
    Input('clear-list', 'n_clicks'),
    Input('start-traversal', 'n_clicks'),
    Input('interval-component', 'n_intervals'),
    State('node-value', 'value'),
    State('speed-slider', 'value'),
    State('interval-component', 'disabled')
)
def update_graph_and_info(add_clicks, remove_clicks, clear_clicks, start_traversal_clicks, n_intervals, node_value, speed, is_interval_disabled):
    ctx = dash.callback_context
    nodes_with_indices = cll.to_list_with_indices()
    highlight_node = None

    if not ctx.triggered:
        return plotly_circular_linked_list(cll), update_info(None), is_interval_disabled, int(1000 / speed), update_traversal_info(speed)

    button_id = ctx.triggered[0]['prop_id'].split('.')[0]

    if button_id == 'add-node' and add_clicks > 0:
        new_data = node_value if node_value is not None else len(nodes_with_indices) + 1
        cll.insert_end(new_data)
    elif button_id == 'remove-node' and remove_clicks > 0:
        cll.remove_end()
    elif button_id == 'clear-list' and clear_clicks > 0:
        cll.clear()
    elif button_id == 'start-traversal' and start_traversal_clicks > 0:
        if is_interval_disabled:
            return plotly_circular_linked_list(cll), update_info(None), False, int(1000 / speed), update_traversal_info(speed)
        else:
            return plotly_circular_linked_list(cll), update_info(None), True, int(1000 / speed), update_traversal_info(speed)

    if not is_interval_disabled and button_id == 'interval-component':
        if nodes_with_indices:
            index = n_intervals % len(nodes_with_indices)
            highlight_node = f"{nodes_with_indices[index][0]}_{index}"
            return plotly_circular_linked_list(cll, highlight_node), update_info(None), False, int(1000 / speed), update_traversal_info(speed, nodes_with_indices[index][0])

    return plotly_circular_linked_list(cll), update_info(None), is_interval_disabled, int(1000 / speed), update_traversal_info(speed)

# Run the app
if __name__ == '__main__':
    app.run_server(debug=True)
