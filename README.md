# Project 1 - Flicks

Flicks is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 10 hours spent in total

## User Stories

The following **required** functionality is completed:

- [√] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [√] User can view movie details by tapping on a cell.
- [√] User sees loading state while waiting for the API.
- [√] User sees an error message when there is a network error.
- [√] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [√] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [√] Implement segmented control to switch between list view and grid view.
- [√] Add a search bar.
- [√] All images fade in.
- [√] For the large poster, load the low-res image first, switch to high-res when complete.
- [√] Customize the highlight and selection effect of the cell.
- [√] Customize the navigation bar.

The following **additional** features are implemented:

- [√] Load predefined image when movie poster not available
- [√] Translate digital date to English date format

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://github.com/kaileding/iOS_Flicks/blob/master/demo1.gif' title='normal operations' width='' alt='Video Walkthrough' />
<img src='https://github.com/kaileding/iOS_Flicks/blob/master/demo2.gif' title='normal operations' width='' alt='Video Walkthrough' />
<img src='https://github.com/kaileding/iOS_Flicks/blob/master/demo3.gif' title='normal operations' width='' alt='Video Walkthrough' />
<img src='https://github.com/kaileding/iOS_Flicks/blob/master/demo4.gif' title='network error' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- I tried to fade in a background image of the movie when user taps on the table cell (highlighted), but the backgraound image shows on the entire screen instead of being constrainted within the single cell.
- I didn't put effort to get every information from API about the film to show in the details page (i.e. the rate and duration of the film), which may not be relevant to the objective of this project.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
