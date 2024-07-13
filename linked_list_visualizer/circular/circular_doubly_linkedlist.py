import dash
from dash import dcc, html, Input, Output, State, callback_context
import plotly.graph_objects as go
import networkx as nx
import numpy as np


class DoublyNode:
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None

class DoublyCircularLinkedList:
    def __init__(self):
        self.head = None

    def insert_end(self, data):
        new_node = DoublyNode(data)
        if self.head is None:
            self.head = new_node
            new_node.next = self.head
            new_node.prev = self.head
        else:
            tail = self.head.prev
            tail.next = new_node
            new_node.prev = tail
            new_node.next = self.head
            self.head.prev = new_node

    def remove_end(self):
        if self.head is None:
            return
        elif self.head.next == self.head:
            self.head = None
        else:
            tail = self.head.prev
            new_tail = tail.prev
            new_tail.next = self.head
            self.head.prev = new_tail

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

dcll = DoublyCircularLinkedList()

def create_doubly_circular_linked_list_graph(dcll):
    G = nx.DiGraph()
    nodes_with_indices = dcll.to_list_with_indices()

    if not nodes_with_indices:
        return None, None

    for data, idx in nodes_with_indices:
        G.add_node(f"{data}_{idx}")

    if len(nodes_with_indices) > 1:
        for i in range(len(nodes_with_indices)):
            data, idx = nodes_with_indices[i]
            next_data, next_idx = nodes_with_indices[(i + 1) % len(nodes_with_indices)]
            prev_data, prev_idx = nodes_with_indices[(i - 1) % len(nodes_with_indices)]
            G.add_edge(f"{prev_data}_{prev_idx}", f"{data}_{idx}", color='blue') 
            G.add_edge(f"{data}_{idx}", f"{next_data}_{next_idx}", color='black') 

    pos = nx.circular_layout(G)
    return G, pos


def plotly_doubly_circular_linked_list(dcll, highlight_node=None):
    NODE_RADIUS = 0.2
    NODE_SIZE = 30
    EDGE_WIDTH = 4
    G, pos = create_doubly_circular_linked_list_graph(dcll)

    if G is None:
        return go.Figure()

    fig = go.Figure()

    node_colors = ['lightblue'] * len(G.nodes())
    nodes_with_indices = dcll.to_list_with_indices()
    head_node = nodes_with_indices[0][0] if nodes_with_indices else None
    tail_node = nodes_with_indices[-1][0] if nodes_with_indices else None
    if head_node:
        node_colors[list(G.nodes()).index(f"{head_node}_0")] = 'lightcoral'
    if tail_node:
        node_colors[list(G.nodes()).index(f"{tail_node}_{len(nodes_with_indices) - 1}")] = 'lightyellow'

    if highlight_node:
        if highlight_node in G.nodes():
            node_colors[list(G.nodes()).index(highlight_node)] = 'lightgreen'

    for node, color in zip(G.nodes(), node_colors):
        x, y = pos[node]
        fig.add_trace(go.Scatter(
            x=[x],
            y=[y],
            mode='markers+text',
            marker=dict(size=NODE_SIZE, color=color, line=dict(width=3, color='black')),  
            text=node.split('_')[0],  
            textposition='middle center',
            showlegend=False
        ))

    for edge in G.edges():
        x0, y0 = pos[edge[0]]
        x1, y1 = pos[edge[1]]

        dx = x1 - x0
        dy = y1 - y0
        length = np.sqrt(dx**2 + dy**2)

        if length == 0:
            continue

        # Normalize direction vector
        dx /= length
        dy /= length

        # Adjust edge length to avoid node overlap
        x1_adjusted = x0 + (length - NODE_RADIUS * 1.5) * dx
        y1_adjusted = y0 + (length - NODE_RADIUS * 1.5) * dy

        # Add arrows to show direction
        fig.add_annotation(
            x=x1_adjusted,
            y=y1_adjusted,
            ax=x0,
            ay=y0,
            xref='x',
            yref='y',
            axref='x',
            ayref='y',
            text='',
            showarrow=True,
            arrowhead=2,
            arrowsize=1,
            arrowwidth=EDGE_WIDTH,
            arrowcolor='blue'
        )

        fig.add_annotation(
            x=x0 + (length - NODE_RADIUS * 1.5) * dx,
            y=y0 + (length - NODE_RADIUS * 1.5) * dy,
            ax=x1,
            ay=y1,
            xref='x',
            yref='y',
            axref='x',
            ayref='y',
            text='',
            showarrow=True,
            arrowhead=2,
            arrowsize=1,
            arrowwidth=EDGE_WIDTH,
            arrowcolor='blue'
        )

    fig.update_layout(
        title='Doubly Circular Linked List Visualization',
        showlegend=False,
        xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
        yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
        plot_bgcolor='white'
    )

    return fig


def update_info(dcll):
    nodes = dcll.to_list_with_indices()
    if nodes:
        head_node = nodes[0][0]
        tail_node = nodes[-1][0]
        info = f'Current Nodes: {[data for data, idx in nodes]}\nHead: {head_node}\nTail: {tail_node}'
    else:
        info = 'The list is empty.'
    return info


def update_traversal_info(speed, current_node=None):
    if current_node:
        return f'Traversal Speed: {speed}x\nCurrent Node: {current_node}'
    return f'Traversal Speed: {speed}x'


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
    ctx = callback_context
    nodes_with_indices = dcll.to_list_with_indices()
    highlight_node = None

    if not ctx.triggered:
        return plotly_doubly_circular_linked_list(dcll), update_info(dcll), is_interval_disabled, int(1000 / speed), update_traversal_info(speed)

    button_id = ctx.triggered[0]['prop_id'].split('.')[0]

    if button_id == 'add-node' and add_clicks > 0:
        try:
            new_data = int(node_value) if node_value is not None else len(nodes_with_indices) + 1
            if new_data not in [data for data, idx in nodes_with_indices]:
                dcll.insert_end(new_data)

                
                return plotly_doubly_circular_linked_list(dcll), update_info(dcll), is_interval_disabled, int(1000 / speed), update_traversal_info(speed)
        except ValueError:
            pass  

    elif button_id == 'remove-node' and remove_clicks > 0:
        dcll.remove_end()
    elif button_id == 'clear-list' and clear_clicks > 0:
        dcll.clear()
    elif button_id == 'start-traversal' and start_traversal_clicks > 0:
        if is_interval_disabled:
            return plotly_doubly_circular_linked_list(dcll), update_info(dcll), False, int(1000 / speed), update_traversal_info(speed)
        else:
            return plotly_doubly_circular_linked_list(dcll), update_info(dcll), True, int(1000 / speed), update_traversal_info(speed)

    if not is_interval_disabled and button_id == 'interval-component':
        if nodes_with_indices:
            index = n_intervals % len(nodes_with_indices)
            highlight_node = f"{nodes_with_indices[index][0]}_{index}"
            return plotly_doubly_circular_linked_list(dcll, highlight_node), update_info(dcll), False, int(1000 / speed), update_traversal_info(speed, nodes_with_indices[index][0])

    return plotly_doubly_circular_linked_list(dcll), update_info(dcll), is_interval_disabled, int(1000 / speed), update_traversal_info(speed)



if __name__ == '__main__':
    app.run_server(debug=True)
