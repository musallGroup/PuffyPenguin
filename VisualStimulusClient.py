import socket
from numpy import sort
from time import time, sleep
import sys
from os import path
from glob import glob
try:
    from modules.VisualStimulus import VisualStimulus
except:
    from VisualStimulus import VisualStimulus
#


class MyClient:
    def __init__(self):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        # connection to localhost on the port.
        self.port = 5005
        self.s.bind(('0.0.0.0', self.port))
        self.s.settimeout(0.02)
        print('Connected to port: ', self.port)
    #

    def read(self):
        try:
            data, addr = self.s.recvfrom(1024)

            if data == b'Close':
                print("Close")
                self.s.close()
                raise Exception('Quit')
            if data == b'Ping':
                self.s.sendto(b'Pong', addr)
                print('received ping')
                data = []
            if data != b'':
                print(data)
            else:
                data = []
        except socket.timeout:
            data = []
        except Exception as e:
            raise e
        #

        return data
    #

    def close(self):
        self.s.close()
        sleep(1.)
        sys.exit(0)
    #
#


if __name__ == '__main__':
    root_path = r'E:\Bpod Local\visualStim'
    left_monitor_id = 0
    right_monitor_id = 1

    # start TCP-client
    client = MyClient()
    gray_path_r = path.join(root_path, 'Stimulus_frames', 'gray_r.png')
    gray_path_l = path.join(root_path, 'Stimulus_frames', 'gray_l.png')

    # open the windows
    vis_stim_l = VisualStimulus(screen=left_monitor_id, screen_size=(1920, 1080), wait_blanking=False, fullscr=False)
    vis_stim_r = VisualStimulus(screen=right_monitor_id, screen_size=(1920, 1080), wait_blanking=True, fullscr=False)

    vis_stim_l.change_image(gray_path_l)
    vis_stim_r.change_image(gray_path_r)
    vis_stim_l.draw()
    vis_stim_r.draw()
    vis_stim_l.flip()
    vis_stim_r.flip()

    while 1:
        data = client.read()
        if not data:
            vis_stim_l.change_image(gray_path_l)
            vis_stim_r.change_image(gray_path_r)

            vis_stim_l.draw()
            vis_stim_r.draw()
            vis_stim_l.flip()
            vis_stim_r.flip()
        else:
            data = data.decode().split(';')
            left_folder = sort(glob(path.join(data[0], '*.png')))
            right_folder = sort(glob(path.join(data[1], '*.png')))
            st = time()
            while True:
                frame_id = round((time() - st) * 60)  # 60 Hz
                if frame_id < len(left_folder):  # 180
                    vis_stim_l.change_image(left_folder[frame_id])
                else:
                    vis_stim_l.change_image(gray_path_l)
                #

                if frame_id < len(right_folder):  # 180
                    vis_stim_r.change_image(right_folder[frame_id])
                else:
                    vis_stim_r.change_image(gray_path_r)
                #

                vis_stim_l.draw()
                vis_stim_r.draw()
                vis_stim_l.flip()
                vis_stim_r.flip()
                if frame_id >= len(left_folder) & frame_id >= len(right_folder):
                    break
                #
            #

            # mandatory gray frame
            vis_stim_l.change_image(gray_path_l)
            vis_stim_r.change_image(gray_path_r)

            vis_stim_l.draw()
            vis_stim_r.draw()
            vis_stim_l.flip()
            vis_stim_r.flip()
        #
    #
#
